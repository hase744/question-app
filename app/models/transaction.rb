class Transaction < ApplicationRecord
  belongs_to :seller, class_name: "User", foreign_key: :seller_id
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id
  belongs_to :service, class_name: "Service", foreign_key: :service_id

  has_many :transaction_messages, foreign_key: :transaction_id, dependent: :destroy
  has_many :transaction_categories, class_name: "TransactionCategory", dependent: :destroy
  has_many :likes, class_name: "TransactionLike", dependent: :destroy
  has_many :items, class_name: "DeliveryItem", foreign_key: :transaction_id, dependent: :destroy
  has_many :point_records, dependent: :destroy
  has_many :balance_records, dependent: :destroy
  has_many :coupon_usages, dependent: :destroy
  has_many :coupons, through: :coupon_usages, dependent: :destroy
  has_one :transaction_category
  has_one :category, through: :transaction_category
  has_one :review
  has_one :latest_transaction_message, -> { order(created_at: :desc) }, class_name: 'TransactionMessage'

  delegate :user, to: :service
  validates :title, length: {maximum: :title_max_length}
  validates :description, length: {maximum: :description_max_length}
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: :price_minimum_number, less_than_or_equal_to: :price_max_number}, presence: true, if: -> { mode == 'proposal' }
  validates :reject_reason, length: {maximum: :reject_reason_max_length}
  validates :disable_reason, presence: true, if: :is_violation?
  validates :disabled_at, presence: true, if: :is_violation?
  validates :delivery_time, presence: true
  validate :validate_price, if: -> { mode == 'proposal' }
  validate :validate_title
  validate :validate_description
  validate :validate_is_canceled
  validate :validate_item
  validate :validate_is_rejected
  validate :validate_reject_reason
  validate :validate_is_suggestion
  validate :validate_item_count
  validate :validate_is_disabled
  validate :previous_transaction
  validate :validate_service_renewed
  validate :validate_violation
  #validate :validate_transaction_category #なぜか保存前にbuildできないためtransaction保存後にcategoryを保存
  before_validation :set_default_values
  enum mode: { proposal: 0, tip: 1 }

  after_save :create_transaction_category
  after_save :update_total_sales
  after_save :create_payment_record
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
      {service: :item}, 
      {request: :items}, 
      {transaction_messages: :sender}, 
      {transaction_messages: :receiver}
    ).includes(transaction_messages: [:sender, :receiver])
  }

  scope :valid, -> {
    where(is_disabled: false)
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

  scope :from_coupon, -> (coupon){
    self.solve_n_plus_1
      .left_joins(:coupon_usages)
      .where(
        coupon_usages: {coupon: coupon},
        )
  }

  scope :not_transacted, -> {
    where(
      is_transacted: false,
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

  def set_default_values
    self.delivery_time ||= DateTime.now + self.service.delivery_days.to_i
    self.price ||= self.service.price
    self.margin ||= self.service.price*transaction_margin.to_f
    self.profit ||= (self.price - self.margin)
    self.service_checked_at ||= DateTime.now
    self.disabled_at ||= DateTime.now if self.is_disabled

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

    if is_tip_mode?
      self.transaction_message_enabled = true
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

  def set_contraction
    self.assign_attributes(
      is_contracted: true,
      contracted_at: DateTime.now,
      delivery_time: DateTime.now + self.service.delivery_days.to_i
      )
  end

  def set_delivery
    self.assign_attributes(
      is_published: true,
      published_at: DateTime.now,
    )
    unless is_tip_mode?
      self.assign_attributes(
        is_transacted: true,
        transacted_at: DateTime.now,
      )
    end
  end

  def set_cansel
    self.assign_attributes(
      is_canceled: true, 
      canceled_at: DateTime.now
      )
  end

  def set_rejection
    self.assign_attributes(
      is_rejected: true, 
      rejected_at: DateTime.now
      )
  end

  def validate_is_suggestion
    return unless self.is_suggestion && self.service.request_id.blank?
    if self.request.user.is_deleted
      errors.add(:buyer,  "アカウントが存在しません。")
    elsif !self.request.user.is_stripe_customer_valid?
      errors.add(:buyer,  "質問者の決済が承認されていません。")
    elsif self.request.request_form.name != self.service.request_form.name && self.request_form.name != 'free'
      errors.add(:request_form,  "質問形式が違います")
    elsif self.request.category.name != self.service.category.name && self.request.category.parent_category&.name != self.service.category.name
      errors.add(:base,  "カテゴリが違います")
    elsif self.service.request_max_characters && self.service.request_max_characters < self.request.description.length
      errors.add(:base,  "相談室の文字数が不足しています")
    else
      nil
    end
  end

  def required_points
    coupon_model = appropriate_coupons
    return self.price if coupon_model.nil?
    if coupon_model.is_a?(Coupon) #単体のクーポンの時 == one_timeの時
      self.price - ([coupon_model.remaining_amount, self.price].min*coupon_model.discount_rate).to_i
    else #unlimitedの時は必ず、discount_rate= 1.00なので考慮しなくていい
      self.price - [self.price, coupon_model.to_a.sum(&:remaining_amount)].min
    end
  end

  def build_coupon_usages
    coupon_model = appropriate_coupons
    return if coupon_model.nil?
    if coupon_model.is_a?(Coupon) #単体のクーポンの時 == one_timeの時
      self.coupon_usages.build(amount: [coupon_model.remaining_amount, self.price].min*coupon_model.discount_rate, coupon: coupon_model)
    else #複数のクーポンの時 = unlimitedの時
      #unlimitedの時は必ず、discount_rate= 1.00なので割引率は考慮しなくていい
      discounted_price = self.price
      coupon_model.each do |coupon|
        break if discounted_price == 0
        amount_to_discount = [discounted_price, coupon.remaining_amount].min
        self.coupon_usages.build(amount: amount_to_discount, coupon: coupon)
        discounted_price -= amount_to_discount
      end
    end
  end

  def destroy_all_coupons
    return true if self.coupon_usages.blank?
    response = self.coupon_usages.respond_to?(:destroy_all)
    if response
      coupon_ids = self.coupons.pluck(:id)
      self.coupon_usages&.destroy_all
      Coupon.where(id: coupon_ids).each(&:save)
    else
      errors.add(:coupon_usages, "クーポンに関するエラー")
    end
    response
  end

  def appropriate_coupons
    unless self.buyer.use_inactive_coupon
      active_coupons = self.buyer.coupons
        .usable(price)
        .where(is_active: true)
      return active_coupons.first if active_coupons.count == 1
      return active_coupons if active_coupons
    end
    latest_coupon = get_latest_coupon
    if latest_coupon&.usage_type == 'one_time'
      return latest_coupon
    elsif latest_coupon&.usage_type == 'unlimited'
      return unlimited_coupons
    else #クーポンが存在しない
      return nil
    end
  end

  def get_latest_coupon
    self.buyer.coupons
      .usable(price)
      .order(end_at: :asc)
      .first
  end

  def unlimited_coupons
    unlimitd_coupons = self.buyer.coupons
      .usable(self.price)
      .where(usage_type: 'unlimited')
      .order(end_at: :asc)
    selected_coupon_ids = []
    sum = 0
    unlimitd_coupons.each do |coupon|
      selected_coupon_ids << coupon
      sum += coupon.remaining_amount
      break if sum >= self.price
    end
    unlimitd_coupons.where(id: selected_coupon_ids)
  end

  def previous_transaction
    previous_transaction = Transaction.where(
      request: self.request, 
      service: self.service
    ).where.not(id: self.id)
    if previous_transaction.present?
      if self.is_suggestion
        errors.add(:is_suggestion, "既に提案済みです")
      else
        errors.add(:is_suggestion, "既に質問済みです")
      end
    end
  end

  def validate_transaction_category
    unless self.transaction_categories.present?
      errors.add(:transaction_categories, 'カテゴリーが選択されていません')
      throw(:abort)
    end

    if self.transaction_categories.count > 1
      errors.add(:transaction_categories)
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
  
  def update_request
    self.request.update(
      deal:self
    )
  end

  def create_payment_record
    return if saved_change_to_id? #新規のデータの時、return
    discounted_price = self.price - self.coupon_usages.sum(:amount)
    if self.saved_change_to_is_canceled? && discounted_price > 0
      self.point_records.create(
        user: self.buyer,
        deal: self,
        amount: discounted_price,
        type_name: 'cancel',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_contracted? && discounted_price > 0
      self.point_records.create(
        user: self.buyer,
        deal: self,
        amount: -discounted_price,
        type_name: 'contract',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_rejected? && discounted_price > 0
      self.point_records.create(
        user: self.buyer,
        amount: discounted_price,
        type_name: 'rejection',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_transacted? && self.profit > 0
      self.balance_records.create(
        user: self.seller,
        amount: self.profit,
        type_name: 'deal',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_disabled? && 
    self.is_transacted && 
    discounted_price > 0 && 
    self.balance_records.count == 1
      self.balance_records.create(
        user: self.seller,
        amount: -self.profit,
        type_name: 'violation',
        created_at: self.updated_at,
      )
    end
    if self.saved_change_to_is_disabled? && 
    self.is_contracted && 
    self.profit > 0 && 
    self.point_records.count == 1
      self.point_records.create(
        user: self.buyer,
        deal: self,
        amount: discounted_price,
        type_name: 'violation',
        created_at: self.updated_at,
      )
    end
  end

  def validate_title
    if self.title.present?
      errors.add(:title, "ひとこと回答を入力して下さい") if self.title.length <= 0 && self.is_published
    else
      errors.add(:title, "ひとこと回答を入力して下さい") if self.is_published
    end
  end

  def validate_description
    if self.description.present?
      errors.add(:description, "本文を入力して下さい") if self.description.length <= 0 && self.is_published
    else
      errors.add(:description, "本文を入力して下さい") if self.is_published
    end
  end

  def validate_item
    return unless self.is_published
    request_form_names = self.request.items.map{|item| item.file.form_name}.uniq
    case self.request_form.name
    when 'image'
      if request_form_names.length > 0 && request_form_names[0] != 'image'
        errors.add(:request_form, '画像を添付してください')
      end
    when 'text'
      if self.request.need_text_image?
        errors.add(:request_form, 'ファイルを削除してください') if !self.request.has_only_text_image?
      elsif request_form_names.length > 0
        errors.add(:request_form, 'ファイルを削除してください')
      end
    end

    delivery_form_names = self.request.items.map{|item| item.file.form_name}.uniq
    case self.delivery_form_name
    when 'image'
      if delivery_form_names.length > 0 && delivery_form_names[0] != 'image'
        errors.add(:request_form, '画像を添付してください')
      end
    end
  end

  def is_cancelable_by(user)
    return false if user != self.buyer
    return false if DateTime.now < self.delivery_time
    return false if self.is_rejected 
    return false if self.is_transacted
    true
  end

  def validate_is_canceled
    return unless self.is_canceled 
    errors.add(:delivery_time, "納品期限を過ぎていません") if DateTime.now < self.delivery_time
    errors.add(:is_canceled, "キャンセルはできません") if self.is_rejected || self.is_transacted
  end
  
  def validate_is_rejected
    if (self.is_transacted || self.is_canceled) && self.is_rejected #納品済み または　キャンセル済み
      errors.add(:is_rejected, "お断りは現在できません")
    end
  end

  def validate_reject_reason
    if (self.is_transacted || self.is_canceled) && self.reject_reason.present? #納品済み または　キャンセル済み
      errors.add(:reject_reason, "お断り理由は現在、作成できません")
    end
  end

  def validate_service_renewed
    if self.request.is_published && self.request.will_save_change_to_is_published? && self.service_checked_at < self.service.renewed_at
      errors.add(:service, "相談室の内容が変更されました")
    end
  end

  def validate_violation
    if !self.is_disabled && is_disabled_changed?
      errors.add(:is_disabled, "cannot be changed if is_violation is true")
    end
  end

  def total_likes
    self.likes.count
  end

  def messages_sort_by_later
    transaction_messages.to_a.sort_by(&:created_at).reverse
  end

  def messages_sort_by_earlier
    transaction_messages.to_a.sort_by(&:created_at)
  end

  def latest_message_body
    messages_sort_by_later.last.body
  end
  
  def latest_message_created_at
    messages_sort_by_later.last.created_at
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
    if is_tip_mode?
      return DateTime.now < self.request.suggestion_deadline
    end
    if self.is_contracted
      self.transaction_message_enabled || user == self.seller
    else
      can_send_pre_purchase_inquiry(user)
    end
  end

  def can_send_pre_purchase_inquiry(user)
    return false unless self.service.allow_pre_purchase_inquiry
    return false if self.is_contracted
    if user == self.seller #回答者の時
      messages_sort_by_later.last&.receiver == user
    elsif user == self.buyer #質問者の時
      messages_sort_by_later.last&.receiver == user || self.transaction_messages.blank?
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

  def category_names
    self.categories.map{|c| c.japanese_name}.join(',')
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

  def is_violation?
    is_disabled
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
    errors.add(:items, "納品ファイルの数は#{self.max_items_count}個までです")
  end

  def validate_is_disabled
    return unless self.is_disabled
    if will_save_change_to_is_transacted? ||
      will_save_change_to_is_published? ||
      will_save_change_to_title? ||
      will_save_change_to_description?
      errors.add(:is_transacted, '規約違反のため修正できません')
    end
  end
  
  def max_items_count
    10
  end
end
