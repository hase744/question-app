class Service < ApplicationRecord
  has_many :requests
  has_many :files, class_name: "ServiceFile", dependent: :destroy
  has_many :transactions, class_name: "Transaction", dependent: :destroy
  has_many :ongoing_transactions, class_name: "Transaction", dependent: :destroy
  has_many :reviews, through: :transactions
  has_many :service_categories, class_name: "ServiceCategory", dependent: :destroy
  has_one :service_category
  has_one :item, class_name: "ServiceItem", dependent: :destroy
  has_many :items, class_name: "ServiceItem", dependent: :destroy
  has_many :requests, through: :transactions
  has_many :likes, class_name: "ServiceLike"
  belongs_to :request, optional: true
  belongs_to :user
  before_validation :set_default_values
  before_validation :update_renewed_at

  delegate :category, to: :service_category, allow_nil: true
  after_save :update_total_services
  #after_save :update_user_service_mini_price
  attr_accessor :request_max_minutes
  attr_accessor :category_id

  validates :title, length: {maximum: :title_max_length}, presence: true, if: -> { mode == 'proposal' }
  validates :description, length: {maximum: :description_max_length}, presence: true, if: -> { mode == 'proposal' }
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: :price_minimum_number, less_than_or_equal_to: :price_max_number}, presence: true, if: -> { mode == 'proposal' }
  validates :delivery_days, numericality: {only_integer: true, fgreater_than_or_equal_to: :delivery_days_minimum_number, less_than_or_equal_to: :delivery_days_max_number}, presence: true, if: -> { mode == 'proposal' }
  validate :validate_price, if: -> { mode == 'proposal' }
  validate :validate_request_max_duration, if: -> { mode == 'proposal' }
  validate :validate_service_category, if: -> { mode == 'proposal' }
  enum request_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  enum delivery_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :service_categories, allow_destroy: true
  enum mode: { proposal: 0, reward: 1 }

  scope :solve_n_plus_1, -> {
    includes(:user, :transactions, :reviews, :requests, :service_categories, :service_category, :item)
  }

  scope :buyable, -> {
    solve_n_plus_1
    .abled
    .not_reward_mode
    .where(
      request_id: nil,
      is_published: true,
      is_for_sale: true,
    )
  }

  scope :seeable, -> {
    left_joins(:user, :service_categories)
    .solve_n_plus_1
    .abled
    .not_reward_mode
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

  scope :displayable, -> (user=nil){
    if user
      not_reward_mode
    else
      not_reward_mode
      .where(is_published:true, request_id: nil)
    end
  }

  scope :sort_by_total_sales_numbers, -> {
    left_joins(:transactions)
      .select('services.*, COUNT(CASE WHEN transactions.is_canceled = false AND transactions.is_rejected = false AND transactions.is_contracted = true THEN 1 END) AS total_sales_numbers')
      .group('services.id')
      .order('total_sales_numbers DESC')
  }

  scope :sort_by_average_star_rating, -> {
    order(Arel.sql('average_star_rating DESC NULLS LAST'))
    #left_joins(:reviews)
    #  .select('services.*, AVG(reviews.star_rating) AS average_star_rating')
    #  .group('services.id')
    #  .order('average_star_rating DESC')
  }

  scope :sort_by_default, ->{ #is_published=trueとなっている一番最新のtransactionのpublished_atが新しい順にserviceをソート
    left_joins(:transactions, :likes)
      .select('services.*, MAX(CASE WHEN transactions.is_published = true THEN transactions.published_at ELSE NULL END) AS latest_published_at')
      .group('services.id')
      .order(Arel.sql('latest_published_at DESC NULLS LAST'))
      .order('COUNT(service_likes.id) DESC')
      .order(created_at: :desc)
  }

  scope :sort_by_likes, -> {
    left_joins(:likes)
      .group('services.id')
      .order('COUNT(service_likes.id) DESC')
  }

  scope :with_reviews_count, -> {
    left_joins(:reviews)
      .select('services.*, COUNT(reviews.id) AS reviews_count')
      .group('services.id')
  }

  scope :transactions_count, -> {
    left_joins(:transactions)
      .select('services.*, COUNT(CASE WHEN transactions.is_published = true THEN 1 END) AS published_transactions_count')
      .group('services.id')
      .order('published_transactions_count DESC')
  }

  scope :sort_by_price, -> {
    order(price: :ASC)
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

  def total_likes
    self.likes.count
  end

  def is_inclusive
    self.request_id == nil
  end

  scope :with_minimum_rating, ->(min_rating) {
    joins(:reviews)
      .select('services.*, AVG(reviews.star_rating) as average_rating')
      .group('services.id')
      .having('AVG(reviews.star_rating) >= ?', min_rating)
  }

  def exclusive_transaction
    Transaction.find_by(
      service: self,
      request: self.request
    )
  end

  def attributes_to_check
    [
      "title", 
      "description", 
      "price",
      "request_form_name", 
      "delivery_form_name", 
      "delivery_days", 
      "request_max_characters",
      "request_max_duration",
      "transaction_message_enabled",
      "service_category",
      "allow_pre_purchase_inquiry",
    ]
  end

  def update_renewed_at
    attributes_to_check.each do |a| #更新判定のattributeが更新されている
      if self.changed.include?(a)
          self.renewed_at = DateTime.now()
          break
      end
    end
  end

  def thumb_with_default
    return "/updating_normal_size.jpg" if self.item&.file_processing
    self.item&.file&.thumb&.url.presence || "/corretech_icon.png"
  end

  def update_average_star_rating
    transactions =  Transaction.where(service: self).where.not(star_rating: nil)
    self.update(average_star_rating: transactions.average(:star_rating).to_f)
  end

  def total_sales_numbers #累計売上数
    Transaction.where(
      service:self, 
      is_canceled:false, 
      is_rejected: false, 
      is_contracted:true
    ).count
  end

  def total_sales_amount #累計売上額
    Transaction.where(
      service:self, 
      is_canceled:false, 
      is_rejected: false, 
      is_contracted:true
    ).sum(:price)
  end

  def update_user_service_mini_price
    if self.saved_change_to_price?
      self.user.update_service_mini_price
    end
  end

  def get_unbuyable_message(user)
    if !self.is_for_sale
      "販売停止中です"
    elsif !self.is_published
      "相談室が非公開です"
    elsif self.is_disabled
      "規約違反により凍結されています"
    elsif !self.user.is_published
      "ユーザーが非公開です"
    elsif self.user.is_deleted
      "アカウントが存在しません"
    elsif self.user == user
      "自分の相談室に質問できません"
    elsif !self.user.is_normal
      "回答者のアカウントに問題が発生しました"
    elsif self.request && self.request.user != user
      "購入できません。"
    else
      nil
    end
  end

  def get_unsuggestable_message(request)
    if !self.is_for_sale
      "販売停止中です"
    elsif request.user.is_deleted
      "アカウントが存在しません"
    elsif !request.user.is_stripe_customer_valid?
      "質問者の決済が承認されていません"
    elsif self.request_max_characters && self.request_max_characters < request.description.length
      "相談室の文字数が不足しています"
    else
      nil
    end
  end

  def set_default_values
    self.mode ||= 'proposal'
    if is_reward_mode?
      self.allow_pre_purchase_inquiry = true
    end
  
    if self.is_disabled && will_save_change_to_is_disabled?
      self.disabled_at ||= DateTime.now
      self.is_for_sale = false
    end

    if self.service_categories.length > 1
      if self.categories.length > 1 #カテゴリの種類がたくさんある
        self.service_categories.first.update(
          category_name: self.service_categories.last.category_name
        )
      end
      self.service_categories.last.destroy
    end
    
    self.request_max_characters = nil if self.request_max_characters == 0
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
      self.is_for_sale = true
      self.category_id = self.request.category.id
      self.request_form_name = self.request.request_form_name
      self.request_max_characters = nil
      self.request_max_duration = nil
      self.service_categories_attributes = {"0"=>{"category_name"=> self.request.category.name}}
    elsif self.request_form_name == 'video' && self.is_inclusive
      self.request_max_duration = request_max_minutes.to_i*60
    end
  end

  def update_total_services
    if self.request.present?
      self.request.update(total_services: self.request.services.count)
    end
  end

  def validate_service_category
    unless self.service_categories.present?
      errors.add(:service_categories, 'カテゴリーが選択されていません')
      throw(:abort)
    end
  end

  def update_service_mini_price
  end

  def validate_request_max_duration
    if self.request_form_name == "video"
      if self.request_max_duration.present?
        if self.request_max_duration < 60
            errors.add(:request_max_minutes, "質問動画の最大時間は最低1分です")
        end
        if self.request_max_duration > 600
            errors.add(:request_max_minutes, "質問動画の最大時間は最大10分です")
        end
      elsif !self.request.present? #依頼に対する提案ではない
        errors.add(:request_max_minutes, "質問動画の最大時間に値が空です")
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
    10000
  end

  def self.description_max_length#最大値
    10000
  end

  def max_character_options
    array = []
    array << ['制限なし', 0]
    (100..900).step(100) { |i| array << ["#{i}字", i] }
    (1000..20000).step(1000) { |i| array << ["#{i}字", i] }
    array
  end

  def price_options
    (price_minimum_number..price_max_number)
      .step(100)
      .map { |num| 
        if num == 0
          ["#{num}円（お試し）", num]
        else
          ["#{num}円", num]
        end
      }
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
