class Service < ApplicationRecord
  mount_uploader :image, ImageUploader
  has_many :requests
  has_many :files, class_name: "ServiceFile", dependent: :destroy
  has_many :transactions, class_name: "Transaction", dependent: :destroy
  has_many :service_categories, class_name: "ServiceCategory", dependent: :destroy
  has_one :service_category
  has_many :requests, through: :transactions
  belongs_to :request, optional: true
  belongs_to :user
  before_validation :set_default_values
  before_validation :update_renewed_at

  delegate :category, to: :service_category, allow_nil: true
  after_save :update_total_services
  after_save :update_user_service_mini_price
  attr_accessor :request_max_minutes
  attr_accessor :category_id

  validates :title, length: {maximum: :title_max_length}, presence: true
  validates :description, length: {maximum: :description_max_length}, presence: true
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: :price_minimum_number, less_than_or_equal_to: :price_max_number}, presence: true
  validates :delivery_days, numericality: {only_integer: true, fgreater_than_or_equal_to: :delivery_days_minimum_number, less_than_or_equal_to: :delivery_days_max_number}, presence: true
  validates :stock_quantity, numericality: {only_integer: true, greater_than_or_equal_to: :stock_quantity_minimum_number, less_than_or_equal_to: :stock_quantity_max_number}#, presence: true
  validates :transaction_message_days, numericality: {only_integer: true, greater_than_or_equal_to: :minimum_transaction_message_days, less_than_or_equal_to: :max_transaction_message_days}, presence: true
  validate :validate_price
  validate :validate_request_max_length
  validate :validate_request_max_duration
  enum request_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  enum delivery_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  accepts_nested_attributes_for :service_categories, allow_destroy: true

  scope :solve_n_plus_1, -> {includes(:user, :requests, :service_categories, :service_category, :transactions)}
  scope :seeable, -> { 
    left_joins(:user, :service_categories)
    .solve_n_plus_1
    .where(
      request_id: nil,
      is_published: true,
      user: {
        is_published: true, 
        state: 'normal',
        is_seller: true,
      }
    )
  }
  
  scope :filter_categories, -> (names){
    if names.present?
      names = names.split(',')
      self.left_joins(:service_categories)
        .where(service_categories: {
          category_name: names
        })
    else
      self
    end
  }

  after_initialize do
    if self.request_form_name == 'video'
      self.request_max_minutes = self.request_max_minutes.to_i if self.request_max_minutes
      if self.request_max_duration.present? && !self.request_max_minutes.present? #最大時間がある かつ、最大分が空
        self.request_max_minutes ||= self.request_max_duration/60
      end
      if self.request_max_minutes
        self.request_max_duration ||= self.request_max_minutes*60
      end
    end
    set_service_content
  end

  def categories
    Category.where(name:self.service_categories.pluck(:category_name))
  end

  def request_form
    Form.find_by(name: self.request_form_name)
  end

  def delivery_form
    Form.find_by(name: self.delivery_form_name)
  end

  def is_inclusive
    self.request_id == nil
  end

  def exclusive_transaction
    Transaction.find_by(
      service: self,
      request: self.request
    )
  end

  def update_renewed_at
    attributes_to_check = [
      "title", 
      "description", 
      "price",
      "request_form_name", 
      "delivery_form_name", 
      "delivery_days", 
      "request_max_characters",
      "request_max_duration",
      "request_max_files",
      "transaction_message_days",
    ]
    attributes_to_check.each do |a| #更新判定のattributeが更新されている
      if self.changed.include?(a)
          self.renewed_at = DateTime.now()
          break
      end
    end
  end

  def thumb_with_default
    if self.image.thumb.url == nil
      "/corretech_icon.png"
    else 
      self.image.thumb.url
    end 
  end
  
  def update_average_star_rating
    transactions =  Transaction.where(service: self).where.not(star_rating: nil)
    self.update(average_star_rating: transactions.average(:star_rating).to_f)
  end

  def update_total_sales_numbers
    transactions = Transaction.where(
      service:self, 
      is_canceled:false, 
      is_rejected: false, 
      is_contracted:true
      )
    self.update(total_sales_numbers: transactions.count)
  end

  def update_total_reviews
    transactions = Transaction.where(service: self).where.not(star_rating: nil)
    self.update(total_reviews: transactions.count)
  end

  def update_user_service_mini_price
    if self.saved_change_to_price?
      self.user.update_service_mini_price
    end
  end

  def get_unbuyable_message(user)
    if  self.stock_quantity && self.stock_quantity < 1
      "売り切れのため購入できません。"
    elsif !self.is_published
      "サービスが非公開です。"
    elsif !self.user.is_published
      "ユーザーが非公開です。"
    elsif self.user.is_deleted
      "アカウントが存在しません。"
    elsif !self.user.is_stripe_account_valid?
      "回答者の決済が承認されていません。"
    elsif !self.user.is_normal
      "回答者のアカウントに問題が発生しました。"
    elsif self.request && self.request.user != user
      "購入できません。"
    else
      nil
    end
  end

  def get_unsuggestable_message(request)
    if  self.stock_quantity < 1
      "在庫が足りません"
    elsif request.user.is_deleted
      "アカウントが存在しません。"
    elsif !request.user.is_stripe_customer_valid?
      "質問者の決済が承認されていません。"
    elsif request.request_form != self.request_form
      "質問形式が違います"
    elsif self.request_max_characters < request.description.length
      "相談室の文字数が足りません"
    else
      nil
    end
  end

  def set_default_values
    if self.service_categories.length > 1
      if self.categories.length > 1 #カテゴリの種類がたくさんある
        self.service_categories.first.update(
          category_name: self.service_categories.last.category_name
        )
      end
      self.service_categories.last.destroy
    end

    if self.request_id
      self.request = Request.find(self.request_id.to_i)
    end
    
    if self.request #依頼に対する提案である
      self.stock_quantity = 1
      self.category_id = self.request.category.id
      self.request_form_name = self.request.request_form_name
      self.request_max_characters = nil
      self.request_max_duration = nil
    elsif self.request_form_name == 'video' && self.is_inclusive
      self.request_max_duration = request_max_minutes.to_i*60
    end
  end

  def update_total_services
    if self.request.present?
      self.request.update(total_services: self.request.services.count)
    end
  end

  def update_service_mini_price
  end

  def validate_price
    if self.price.nil?
      errors.add(:price)
    elsif self.price % 100 != 0
      errors.add(:price, "は100円ごとにしか設定できません")
    elsif self.price <= 0
      errors.add(:price)
    end
  end

  def validate_request_max_duration
    if self.request_form.name == "video"
      if self.request_max_duration.present?
        puts "時間"
        puts self.request_max_duration
        if self.request_max_duration < 60
            errors.add(:request_max_minutes, "は最低1分です")
        end
        if self.request_max_duration > 600
            errors.add(:request_max_minutes, "は最大10分です")
        end
      elsif !self.request.present? #依頼に対する提案ではない
        errors.add(:request_max_minutes, "に値が空です")
      end
    end
  end

  def validate_request_max_length
    if  !self.request.present?
      case self.request_form.name
      when "text"
        #errors.add(:request_max_minutes, "#{max_request_max_characters}が空です") if request_max_characters == nil
        #errors.add(:request_max_characters, "は#{max_request_max_characters}字までです") if self.request_max_characters > max_request_max_characters
        #errors.add(:request_max_characters, "は#{mini_request_max_characters}字以上です") if self.request_max_characters < mini_request_max_characters
      when "video"
        #errors.add(:request_max_minutes, "#{max_request_max_minutes}が空です") if request_max_minutes == nil
        #errors.add(:request_max_minutes, "は#{max_request_max_minutes}分までです") if self.request_max_minutes.to_i > max_request_max_minutes
        #errors.add(:request_max_minutes, "は#{mini_request_max_minutes}字以上です") if self.request_max_minutes.to_i < mini_request_max_minutes
      when "image"
        request_max_files = nil
      else
      end
    end
  end

  def video_display_style
    if self.request_form == 'video'
      'block'
    else
      'none'
    end
  end

  def category_names
    self.categories.map{|c| c.japanese_name}.join(',')
  end

  def title_max_length#最大値
    20
  end

  def description_max_length#最大値
    1000
  end

  
  #価格
  def price_minimum_number#最小値
    100
  end

  def price_max_number#最小値
    10000
  end

  #供給数
  def stock_quantity_max_number#最大値
    100
  end

  def max_transaction_message_days
    30
  end

  def minimum_transaction_message_days
    0
  end

  def stock_quantity_minimum_number#最小値
    0
  end

  #納品日数
  def delivery_days_max_number#最大値
    14
  end

  def delivery_days_minimum_number#最小値
    1
  end

  def max_request_max_characters
    Request.new().description_max_length
  end

  def mini_request_max_characters
    100
  end

  def max_request_max_minutes
    10
  end

  def mini_request_max_minutes
    1
  end

end
