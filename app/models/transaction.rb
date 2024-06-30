class Transaction < ApplicationRecord
  #mount_uploader :file, FileUploader
  #mount_uploader :thumbnail, ImageUploader
  
  belongs_to :seller, class_name: "User", foreign_key: :seller_id
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id
  belongs_to :service, class_name: "Service", foreign_key: :service_id

  has_many :transaction_messages, foreign_key: :transaction_id, dependent: :destroy
  has_many :transaction_categories, class_name: "TransactionCategory", dependent: :destroy
  has_many :likes, class_name: "TransactionLike", dependent: :destroy
  has_many :items, class_name: "DeliveryItem", foreign_key: :transaction_id, dependent: :destroy
  has_many :categories, through: :transaction_categories, dependent: :destroy

  delegate :user, to: :service
  delegate :request_form_name, to: :service
  delegate :delivery_form_name, to: :service
  validates :title, length: {maximum: :title_max_length}
  validates :description, length: {maximum: :description_max_length}
  validates :star_rating, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5, :allow_blank => true}
  validates :review_description, length: {maximum: :review_description_max_length}
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: 100}
  validates :reject_reason, length: {maximum: :reject_reason_max_length}
  validates :delivery_time, presence: true
  validate :validate_price
  validate :validate_title
  validate :validate_description
  validate :validate_is_canceled
  validate :validate_item
  validate :validate_is_rejected
  validate :validate_reject_reason
  validate :validate_review
  validate :validate_is_suggestion
  validate :previous_transaction
  before_validation :set_default_values

  after_save :create_transaction_category
  after_save :update_total_sales
  after_save :update_average_star_rating
  after_save :update_total_reviews
  attr_accessor :use_youtube
  attr_accessor :youtube_id
  attr_accessor :file
  attr_accessor :item
  accepts_nested_attributes_for :items, allow_destroy: true

  after_initialize do
  end

  scope :solve_n_plus_1, -> {
    includes(:seller, :buyer, :request, :service, :items)
  }

  scope :ongoing, -> {
    self.where(
      is_rejected: false,
      is_canceled: false,
      is_delivered: false
    )
  }

  scope :rejected, -> {
    self.where(
      is_rejected: true,
      is_canceled: false,
      is_delivered: false
    )
  }

  scope :undelivered, -> {
    self.where(
      is_rejected: false,
      is_canceled: true,
      is_delivered: false
    ).or(self.where(
      is_rejected: true,
      is_canceled: false,
      is_delivered: false
      )
    )
  }

  scope :delivered, -> {
    self.where(
      is_rejected: false,
      is_canceled: false,
      is_delivered: true
      )
  }
  def set_item
    self.item = self.items.first
    if self.item.present?
      self.file = self.item.file
      self.use_youtube = self.item.use_youtube
      self.youtube_id = self.item.youtube_id
    end
  end
  
  def request_form
    Form.find_by(name: self.request_form_name)
  end

  def delivery_form
    Form.find_by(name: self.delivery_form_name)
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
    if (self.file.present? || self.use_youtube) && self.item
      self.item.assign_attributes(
        file: self.file,
        use_youtube: self.use_youtube,
        youtube_id: self.youtube_id
      )
    end

    if will_save_change_to_request_id?
      if self.is_suggestion
        self.service.category_id = self.request.category_id
      else
        self.request.service = self.service
        self.request.set_service_values
        self.request.request_form_name = self.service.request_form_name
        self.request.delivery_form_name = self.service.delivery_form_name
        self.request.max_price = self.service.price
        self.request.category_id = self.service.category_id
        self.request.suggestion_deadline = DateTime.now + self.service.delivery_days.to_i
      end
    end

    if will_save_change_to_is_contracted?
      self.transaction_message_days = self.service.transaction_message_days
    end

    if will_save_change_to_is_delivered?
      self.transaction_message_deadline = DateTime.now + self.transaction_message_days
    end
    
    self.service_title = self.service.title
    self.service_descriprion = self.service.description
    self.seller = self.service.user
    self.buyer = self.request.user
  end

  def validate_is_suggestion
    if self.is_suggestion && self.service.request_id.nil?
      if self.request.user.is_deleted
        errors.add(:base,  "アカウントが存在しません。")
      elsif !self.request.user.is_stripe_customer_valid?
        errors.add(:base,  "質問者の決済が承認されていません。")
      elsif self.request.request_form.name != self.service.request_form.name
        errors.add(:base,  "質問形式が違います")
      elsif self.service.request_max_characters < self.request.description.length
        errors.add(:base,  "相談室の文字数が足りません")
      else
        nil
      end
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

  def validate_price
    if price % 100 != 0 || price <= 0
      errors.add(:price, "が10の倍数ではありません。")
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
      self.transaction_categories.create(category: self.service.category)
    end
  end

  def update_total_sales
    if self.saved_change_to_is_delivered?
      self.service.update_total_sales_numbers
      self.service.user.update_total_sales_numbers
    end
  end
  
  def update_average_star_rating
    if self.saved_change_to_star_rating?
      self.service.user.update_average_star_rating
      self.service.update_average_star_rating
    end
  end

  def update_total_reviews
    if self.saved_change_to_star_rating?
      self.service.update_total_reviews
      self.service.user.update_total_reviews
    end
  end

  def update_request
    self.request.update(
      deal:self
    )
  end
  
  def update_total_likes
    self.update(
      total_likes: self.likes.count
    )
  end

  def validate_title
    if self.title.present?
      errors.add(:title, "を入力して下さい") if self.title.length <= 0 && self.is_delivered
    else
      errors.add(:title, "を入力して下さい") if self.is_delivered
    end
  end

  def validate_description
    if self.description.present?
      errors.add(:description, "を入力して下さい") if self.description.length <= 0 && self.is_delivered
    else
      errors.add(:description, "を入力して下さい") if self.is_delivered
    end
  end

  def validate_item
    if self.is_published
      if self.items
        if !self.items.first.valid?
          errors.add(:item, "が不適切です")
        end
      else
        errors.add(:item, "がありません")
      end
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

      if self.is_rejected || self.is_delivered
        errors.add(:is_canceled, "はできません")
      end
    end
  end
  
  def validate_is_rejected
    if (self.is_delivered || self.is_canceled) && self.is_rejected #納品済み または　キャンセル済み
      errors.add(:is_rejected, "は現在できません")
    end
  end

  def validate_reject_reason
    if (self.is_delivered || self.is_canceled) && self.reject_reason.present? #納品済み または　キャンセル済み
      errors.add(:reject_reason, "は現在で記入きません")
    end
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
  
  def review_description_max_length
    500
  end

  def is_ongoing
    if self.is_rejected
      false
    elsif self.is_delivered
      false
    elsif self.is_canceled
      false
    else
      true
    end
  end

  #def seller
  #  self.service.user
  #end
#
#
  #def seller_id
  #  self.service.user.id
  #end
#
  #def buyer
  #  self.request.user
  #end
#
  #def buyer_id
  #  self.request.user.id
  #end

  def validate_review
    #レビューに関する情報がひとつでもあるのに、どれかがない
    if self.review_description.present? || self.star_rating.present? || self.reviewed_at.present?
      if !self.review_description.present? || !self.star_rating.present? || !self.reviewed_at.present?
        errors.add(:review_description, "がありません") if !self.review_description.present?
        errors.add(:star_rating, "がありません") if !self.star_rating.present?
        errors.add(:reviewed_at, "がありません") if !self.reviewed_at.present?s
      end
    end
  end

  def review_present?
  end

  def review_nil_present?
  end
end
