class Transaction < ApplicationRecord
  belongs_to :seller, class_name: "User", foreign_key: :seller_id
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id
  belongs_to :service, class_name: "Service", foreign_key: :service_id

  has_many :transaction_messages, foreign_key: :transaction_id, dependent: :destroy
  has_many :transaction_categories, class_name: "TransactionCategory", dependent: :destroy
  has_many :likes, class_name: "TransactionLike", dependent: :destroy
  has_many :items, class_name: "DeliveryItem", foreign_key: :transaction_id, dependent: :destroy
  has_many :point_records
  has_many :balance_records
  has_one :transaction_category
  has_one :category, through: :transaction_category
  has_one :review
  has_one :latest_transaction_message, -> { order(created_at: :desc) }, class_name: 'TransactionMessage'

  delegate :user, to: :service
  validates :title, length: {maximum: :title_max_length}
  validates :description, length: {maximum: :description_max_length}
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: :price_minimum_number, less_than_or_equal_to: :price_max_number}, presence: true
  validates :reject_reason, length: {maximum: :reject_reason_max_length}
  validates :delivery_time, presence: true
  validate :validate_price
  validate :validate_title
  validate :validate_description
  validate :validate_is_canceled
  validate :validate_item
  validate :validate_is_rejected
  validate :validate_reject_reason
  validate :validate_is_suggestion
  validate :validate_item_count
  validate :previous_transaction
  validate :validate_service_renewed
  #validate :validate_transaction_category #なぜか保存前にbuildできないためtransaction保存後にcategoryを保存
  before_validation :set_default_values

  after_save :create_transaction_category
  after_save :update_total_sales
  after_save :update_average_star_rating
  after_save :create_payment_record
  attr_accessor :use_youtube
  attr_accessor :youtube_id
  attr_accessor :file
  attr_accessor :item
  enum request_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  enum delivery_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :transaction_categories, allow_destroy: true

  after_initialize do
  end

  scope :solve_n_plus_1, -> {
    includes(
      :seller, 
      :buyer, 
      :request, 
      :service, 
      :items, 
      :transaction_messages, 
      {request: :items}, 
      {transaction_messages: :sender}, 
      {transaction_messages: :receiver}
    ).includes(transaction_messages: [:sender, :receiver])
  }

  scope :from_seller, -> (user){
    self.solve_n_plus_1
      .left_joins(:service)
      .where(
        service: {user: user}, 
        is_published: true
        )
  }

  scope :from_buyer, -> (user){
    self
      .solve_n_plus_1
      .left_joins(:request)
      .where(
        request: {user: user}, 
        is_published: true
        )
  }

  scope :ongoing, -> {
    self.where(
      is_contracted: true,
      is_rejected: false,
      is_canceled: false,
      is_transacted: false
    )
  }

  scope :rejected, -> {
    self.where(
      is_rejected: true,
      is_canceled: false,
      is_transacted: false
    )
  }

  scope :undelivered, -> {
    self.where(
      is_rejected: false,
      is_canceled: true,
      is_transacted: false
    ).or(self.where(
      is_rejected: true,
      is_canceled: false,
      is_transacted: false
      )
    )
  }

  scope :delivered, -> {
    self.where(
      is_rejected: false,
      is_canceled: false,
      is_transacted: true
      )
  }

  scope :published, -> {
    self.where(
      is_rejected: false,
      is_canceled: false,
      is_published: true
      )
  }

  scope :transacted, -> {
    self.where(
      is_rejected: false,
      is_canceled: false,
      is_transacted: true
      )
  }

  scope :filter_categories, -> (names){
    if names.present?
      names = names.split(',')
      self.left_joins(:transaction_categories)
        .distinct
        .where(transaction_categories: {
          category_name: names
        })
    else
      self
    end
  }

  scope :sort_by_default, ->{
    order(published_at: :DESC)
  }

  scope :sort_by_likes, -> {
    select('transactions.*, COUNT(transaction_likes.id) AS likes_count')
      .left_joins(:likes)
      .group('transactions.id')
      .order('likes_count DESC')
  }

  scope :sort_by_published_at, -> {
    order(published_at: :DESC)
  }

  scope :reviewed, -> {
    joins(:review)
  }

  scope :not_reviewed, -> {
    left_outer_joins(:review).where(reviews: { id: nil })
  }

  scope :by, -> (user){
    left_joins(:service, :request)
    .where(service: {user: user}).or(self.where(request: {user: user}))
  }

  after_initialize do
    set_delivery_content
  end

  def categories
    Category.where(name:self.transaction_categories.pluck(:category_name))
  end

  def total_after_delivered_messages
    self.transaction_messages
      .joins(:deal)
      .where('transaction_messages.created_at > transactions.transacted_at')
      .count
  end

  def set_publish
    self.assign_attributes(is_published:true, published_at:DateTime.now)
  end

  def reset_item
    self.item = nil
    self.file = nil
    self.use_youtube = nil
    self.youtube_id = nil
  end

  def set_default_values
    self.delivery_time ||= DateTime.now + self.service.delivery_days.to_i
    self.price ||= self.service.price
    self.margin ||= self.service.price*transaction_margin.to_f
    self.profit ||= (self.price - self.margin)
    self.service_checked_at ||= DateTime.now
    if (self.file.present? || self.use_youtube) && self.item
      self.item.assign_attributes(
        file: self.file,
        use_youtube: self.use_youtube,
        youtube_id: self.youtube_id
      )
    end

    if new_record?
      self.request_form_name = self.service.request_form.name
      self.delivery_form_name = self.service.delivery_form.name
      if self.is_suggestion
        self.service.category_id = self.request.category_id
      else
        self.request.service = self.service
        self.request.set_service_values
        self.request.request_form_name = self.service.request_form_name
        self.request.delivery_form_name = self.service.delivery_form_name
      end
    end

    if will_save_change_to_is_contracted?
      self.transaction_message_enabled = self.service.transaction_message_enabled
    end

    self.service_title = self.service.title
    self.service_descriprion = self.service.description
    self.service_allow_pre_purchase_inquiry = self.service.allow_pre_purchase_inquiry
    self.seller = self.service.user
    self.buyer = self.request.user
  end

  def copy_from_service
    self.request_form_name = self.service.request_form.name
    self.delivery_form_name = self.service.delivery_form.name
    self.service_title = self.service.title
    self.service_descriprion = self.service.description
    self.transaction_category.category_name = self.service.service_category.category_name
    self.service_allow_pre_purchase_inquiry = self.service.allow_pre_purchase_inquiry
    self.transaction_message_enabled = self.service.transaction_message_enabled
    self.delivery_time = DateTime.now + self.service.delivery_days.to_i
    self.price = self.service.price
    self.margin = self.service.price*transaction_margin.to_f
    self.profit = (self.price - self.margin)
    self.seller = self.service.user
    self.buyer = self.request.user
  end

  def validate_is_suggestion
    if self.is_suggestion && self.service.request_id.nil?
      if self.request.user.is_deleted
        errors.add(:base,  "アカウントが存在しません。")
      elsif !self.request.user.is_stripe_customer_valid?
        errors.add(:base,  "質問者の決済が承認されていません。")
      elsif self.request.request_form.name != self.service.request_form.name && self.request_form.name != 'free'
        errors.add(:base,  "質問形式が違います")
      elsif self.request.category.name != self.service.category.name && self.request.category.parent_category.name != self.service.category.name
        errors.add(:base,  "カテゴリが違います")
      elsif self.service.request_max_characters && self.service.request_max_characters < self.request.description.length
        errors.add(:base,  "相談室の文字数が足りません")
      else
        nil
      end
    else
    end
  end

  def previous_transaction
    previous_transaction = Transaction.where(
      request: self.request, 
      service: self.service
    ).where.not(id: self.id)
    if previous_transaction.present?
      if self.is_suggestion
        errors.add(:base, "既に提案済みです")
      else
        errors.add(:base, "既に質問済みです")
      end
    end
  end

  def validate_transaction_category
    unless self.transaction_categories.present?
      errors.add(:base, 'カテゴリーが選択されていません')
      throw(:abort)
    end

    if self.transaction_categories.count > 1
      errors.add(:base)
      throw(:abort)
    end
  end

  def category
    self.categories.first
  end

  def validate_request
    if will_save_change_to_request_id?
      self.request.service = self.service
      self.request.set_service_values
      #self.request.save if !self.vaid?
    end
  end

  def create_transaction_category #常にself.category.present?=falseなので意味ない
    if !self.category.present?
      self.transaction_categories.create(category_name: self.service.category.name)
    end
  end

  def update_total_sales
    if self.saved_change_to_is_transacted?
      self.service.user.update_total_sales_numbers
    end
  end
  
  def update_average_star_rating
    #if self.saved_change_to_star_rating?
    #  self.service.user.update_average_star_rating
    #  self.service.update_average_star_rating
    #end
  end

  def update_request
    self.request.update(
      deal:self
    )
  end

  def create_payment_record
    return if saved_change_to_id? #新規のデータではない
    if self.saved_change_to_is_canceled?
      self.point_records.create(
        user: self.buyer,
        deal: self,
        amount: self.price,
        type_name: 'cancel',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_contracted?
      self.point_records.create(
        user: self.buyer,
        deal: self,
        amount: -self.price,
        type_name: 'contract',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_rejected?
      self.point_records.create(
        user: self.buyer,
        amount: self.price,
        type_name: 'rejection',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_transacted
      self.balance_records.create(
        user: self.seller,
        amount: self.profit,
        type_name: 'deal',
        created_at: self.updated_at,
      )
    end
  end

  def total_likes
    self.likes.count
  end

  def validate_title
    if self.title.present?
      errors.add(:title, "を入力して下さい") if self.title.length <= 0 && self.is_published
    else
      errors.add(:title, "を入力して下さい") if self.is_published
    end
  end

  def validate_description
    if self.description.present?
      errors.add(:description, "を入力して下さい") if self.description.length <= 0 && self.is_published
    else
      errors.add(:description, "を入力して下さい") if self.is_published
    end
  end

  def validate_item
    return unless self.is_published
    if self.items
      items.each do |item|
        next if item.valid?
        item.errors.full_messages.each do |msg|
          errors.add(:items, msg)
        end
      end
    elsif self.delivery_form.name == "image"
      errors.add(:base, "画像ファイルを添付してください")
    end
  end

  def is_video_extension
    if self.file.present?
      file_extension = File.extname(self.file.path).delete(".")
      if FileUploader.new.extension_allowlist.include?(file_extension) && !ImageUploader.new.extension_allowlist.include?(file_extension)
        true
      else
        false
      end
    else
      false
    end
  end

  def validate_is_canceled
    if self.is_canceled 
      if DateTime.now < self.delivery_time
        errors.add(:delivery_time, "を過ぎていません")
      end

      if self.is_rejected || self.is_transacted
        errors.add(:is_canceled, "はできません")
      end
    end
  end
  
  def validate_is_rejected
    if (self.is_transacted || self.is_canceled) && self.is_rejected #納品済み または　キャンセル済み
      errors.add(:is_rejected, "は現在できません")
    end
  end

  def validate_reject_reason
    if (self.is_transacted || self.is_canceled) && self.reject_reason.present? #納品済み または　キャンセル済み
      errors.add(:reject_reason, "は現在で記入きません")
    end
  end

  def validate_service_renewed
    if self.request.is_published && self.request.will_save_change_to_is_published? && self.service_checked_at < self.service.renewed_at
      errors.add(:base, "相談室の内容が変更されました。")
    end
  end

  def suggestion_buyable(user)
    if user.nil?
      false
    elsif self.service.get_unbuyable_message(user).present?
      false
    elsif self.buyer != user
      false
    elsif !self.is_suggestion
      false
    elsif self.is_contracted
      false
    else
      true
    end
  end

  def can_send_message(user)
    #買った人である。かつ、transaction_messageを送る期限内である
    return false unless user == self.buyer || user == self.seller
    if self.is_contracted
      self.transaction_message_enabled || user == self.seller
    else
      can_send_pre_purchase_inquiry(user)
    end
  end

  def can_send_pre_purchase_inquiry(user)
    return false unless self.service.allow_pre_purchase_inquiry
    return false if self.is_contracted
    if user == self.seller
      self.latest_transaction_message&.receiver == user
    elsif user == self.buyer
      self.latest_transaction_message&.receiver == user || self.transaction_messages.blank?
    else
      false
    end
  end

  def request_form
    Form.find_by(name: self.request_form_name)
  end

  def delivery_form
    Form.find_by(name: self.delivery_form_name)
  end

  def thumb_with_default
    self.items&.first&.file&.thumb&.url.presence || "/profit-300x300.jpg"
  end

  def opponent_of(user)
    if user == self.seller
      self.buyer
    elsif user == self.buyer
      self.seller
    end
  end

  def delete_temp_image
    # Requestなどの親モデルの保存に成功してもrequest_categoryなどの子モデルの保存に失敗すると
    # 保存が失敗した場合のみファイルを削除
    relative_path = self.image.url
    splited_path = relative_path.split('/')
    path_length = splited_path.length
    root_temp_path = Rails.root.to_s + "/tmp/" + splited_path[-2]
    public_temp_path = Rails.root.to_s + "/public/uploads/tmp/" + splited_path[-2]
    delete_folder(root_temp_path)
    delete_folder(public_temp_path)
  end

  def title_max_length
    30
  end

  def reject_reason_max_length
    500
  end

  def description_max_length
    20000
  end

  def is_ongoing
    if !self.is_contracted
      false
    elsif self.is_rejected
      false
    elsif self.is_transacted
      false
    elsif self.is_canceled
      false
    else
      true
    end
  end

  def validate_item_count
    return if self.items.count <= self.max_items_count
    return unless self.will_save_change_to_is_published?
    return unless self.is_published
    errors.add(:items, "の数は#{self.max_items_count}個までです")
  end
  
  def max_items_count
    10
  end
end
