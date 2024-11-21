class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  mount_uploader :image, ImageUploader
  mount_uploader :header_image, ImageUploader
  store_in_background :image
  store_in_background :header_image

  has_many :access_logs, class_name: "AccessLog", foreign_key: :user_id, dependent: :destroy
  has_many :contacts, class_name: "Contact", foreign_key: :user_id, dependent: :destroy
  has_many :contacts, class_name: "Contact", foreign_key: :destination_id, dependent: :destroy
  has_many :messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :messages, class_name: "Message", foreign_key: :receiver_id, dependent: :destroy

  has_many :transaction_messages, class_name: "TransactionMessage", foreign_key: :sender_id, dependent: :destroy
  has_many :transaction_messages, class_name: "TransactionMessage", foreign_key: :receiver_id, dependent: :destroy

  has_many :notifications, class_name: "Notification", foreign_key: :user_id, dependent: :destroy
  has_many :notifications, class_name: "Notification", foreign_key: :notifier_id, dependent: :destroy
  has_many :posts, class_name: "Post", foreign_key: :user_id, dependent: :destroy
  has_many :follower_relationships, -> { follow }, class_name: "Relationship", foreign_key: :target_user_id, dependent: :destroy
  has_many :followee_relationships, -> { follow }, class_name: "Relationship", foreign_key: :user_id, dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :user
  has_many :followees, through: :followee_relationships, source: :target_user
  has_many :requests, class_name: "Request", foreign_key: :user_id, dependent: :destroy
  has_many :services, class_name: "Service", foreign_key: :user_id, dependent: :destroy
  has_many :delivered_transactions, -> { delivered }, class_name: "Transaction", foreign_key: :seller_id, dependent: :destroy
  has_many :buyable_services, -> { buyable.solve_n_plus_1 }, class_name: "Service", foreign_key: :user_id, dependent: :destroy
  has_many :users, class_name: "User", foreign_key: :user_id, dependent: :destroy
  has_many :user_categories, class_name: "UserCategory", dependent: :destroy
  has_many :service_categories, through: :services, source: :service_categories
  has_many :buyable_service_categories, through: :buyable_services, source: :service_categories
  has_many :delivered_transaction_categories, through: :delivered_transactions, source: :transaction_categories
  has_many :deals, class_name: "Transaction", foreign_key: :user_id
  has_many :transaction_likes, class_name: "TransactionLike", foreign_key: :user_id
  has_many :service_likes, class_name: "ServiceLike", foreign_key: :user_id
  has_many :request_likes, class_name: "RequestLike", foreign_key: :user_id
  has_many :payments, dependent: :destroy
  has_many :historyies, dependent: :destroy, class_name: "UserStateHistory", foreign_key: :user_id
  has_many :payouts
  has_many :point_records
  has_many :balance_records
  has_many :sales, class_name: "Transaction", foreign_key: :seller_id, dependent: :destroy
  has_many :purchases, class_name: "Transaction", foreign_key: :buyer_id, dependent: :destroy
  has_many :reviews, through: :sales
  has_many :coupons
  
  validates :name, length: {maximum:15, minimum:1}
  validates :description, length: {maximum: :description_max_length}
  validate :validate_is_published
  validate :validate_registering_is_seller
  validate :validate_unregistering_is_seller
  
  before_validation :set_default_values
  after_commit :create_user_state_hitrory
  after_save :update_image_src
  after_save :update_header_image_src

  attr_accessor :certification
  attr_accessor :first_name_kanji
  attr_accessor :first_name_kana
  attr_accessor :last_name_kanji
  attr_accessor :last_name_kana
  attr_accessor :state_kanji
  attr_accessor :state_kana
  attr_accessor :city_kanji
  attr_accessor :city_kana
  attr_accessor :town_kanji
  attr_accessor :town_kana
  attr_accessor :line1_kanji
  attr_accessor :line2_kanji
  attr_accessor :line2_kana
  attr_accessor :birth_date
  attr_accessor :postal_code
  attr_accessor :first_postal_code
  attr_accessor :last_postal_code
  attr_accessor :bank_number
  attr_accessor :branch_number
  attr_accessor :account_number
  attr_accessor :account_holder_name
  attr_accessor :is_female
  attr_accessor :is_male
  attr_accessor :gender
  attr_accessor :is_dammy
  attr_accessor :old_image_path, :old_image_thumb_url, :old_image_normal_size_url
  enum country_id: Country.all.map{|c| c.name.to_sym}
  enum state: CommonConcern.user_states

  scope :solve_n_plus_1, -> {
    includes(:service_categories, :services, :user_categories)
  }

  scope :include_price, -> {
    left_outer_joins(:buyable_services) #joinsだとserviceが一件もないuserが外れるため
    .select('users.*, MAX(services.price) AS max_price, MIN(services.price) AS mini_price')
    .group('users.id')
  }
  
  scope :is_sellable, -> {
    solve_n_plus_1
    .where(
      is_seller: true,
      is_published: true, 
      state: 'normal'
      )
  }

  scope :filter_categories, -> (names){
    if names.present?
      names = names.split(',')
      self.left_joins(:service_categories)
      .where(service_categories: {
        category_name: names
    })#.distinct
    else
      self
    end
  }

  scope :sort_by_followers, -> {
    left_joins(:follower_relationships)
      .group('users.id')
      .order('COUNT(relationships.id) DESC')
  }

  scope :transactions_count, -> {
    left_joins(:sales)
      .select('users.*, COUNT(CASE WHEN transactions.is_published = true THEN 1 END) AS published_transactions_count')
      .group('users.id')
      .order('published_transactions_count DESC')
  }

  scope :sort_by_default, -> {
    left_joins(:follower_relationships)
      .group('users.id')
      .order('COUNT(relationships.id) DESC')
  }

  scope :with_reviews_count, -> {
    order(total_reviews: :desc)
    #left_joins(:reviews)
    #  .select('users.*, COUNT(reviews.id) AS reviews_count')
    #  .group('users.id')
  }

  def country
    Country.find_by(name: self.country_id)
  end

  def header_with_default
    return "/updating_normal_size.jpg" if self.header_image_processing
    self.header_image.normal_size.url.presence || "/grey.jpg"
  end

  def image_with_default
    return "/updating_normal_size.jpg" if self.image_processing
    self.image.url.presence || "/profile.jpg"
  end

  def normal_image_with_default
    return "/updating_normal_size.jpg" if self.image_processing
    self.image.normal_size.url.presence || "/profile.jpg"
  end

  def thumb_with_default
    return "/updating_thumb.jpg" if self.image_processing
    self.image.thumb.url.presence || "/profile.jpg"
  end

  def image_style_class
    "user-image-#{self.id}"
  end

  def image_thumb_style_class
    "user-image-thumb-#{self.id}"
  end

  def header_style_class
    "header-image-#{self.id}"
  end

  def header_thumb_style_class
    "header-image-thumb-#{self.id}"
  end

  def self.categories
    Category.all.select do |category|
      user_categories.any? { |uc| uc.category_name == category.name }
    end
  end

  def categories
    category_names = self.user_categories
      .order(updated_at: :asc)
      .pluck(:category_name)
    #updated_at順に取得したいので
    category_names.each.map{|name|
      Category.find_by(name: name)
    }
  end

  def is_following?(user)
    self.followee_relationships.where(target_user: user).present?
  end

  def is_followed_by?(user)
    self.follower_relationships.where(user: user).present?
  end

  #def categories
  #  Category.where(name:self.user_categories.pluck(:category_name))
  #end

  #validates :postal_code, format: { with: /\A(?:\d{4}-\d{3}|\d{7})\z/, message: "is not valid. Please enter a valid postal code." }

  def set_default_values
    self.name  ||= "user name"
    self.state ||= :normal
  end

  def create_user_state_hitrory
    if saved_change_to_attribute?(:state)
      UserStateHistory.create(user: self, state: self.state, description: self.admin_description)
    end
  end

  def update_header_image_src
    return unless saved_change_to_attribute?(:header_image_processing) && !self.header_image_processing
    old_header_image_name, new_header_image_name = header_image_previous_change
    update_file_src(
      user: self,
      img_mapping: [
        {
        style_class: header_style_class, 
        img_url: header_with_default
        }
      ]
    )
  end

  def update_image_src
    return unless saved_change_to_attribute?(:image_processing) && !self.image_processing
    old_image_name, new_image_name = image_previous_change
    update_file_src(
      user: self,
      img_mapping: [
        {
        style_class: image_thumb_style_class, 
        img_url: thumb_with_default
        },
        {
        style_class: image_style_class, 
        img_url: image_with_default
        }
      ]
    )
  end

  def delete_temp_file
    # Requestなどの親モデルの保存に成功してもrequest_categoryなどの子モデルの保存に失敗すると
    # 保存が失敗した場合のみファイルを削除
    relative_path = self.file.url
    splited_path = relative_path.split('/')
    path_length = splited_path.length
    root_temp_path = Rails.root.to_s + "/tmp/" + splited_path[-2]
    public_temp_path = Rails.root.to_s + "/public/uploads/tmp/" + splited_path[-2]
    delete_folder(root_temp_path)
    delete_folder(public_temp_path)
  end

  def transactions_from_last_deposit
    #入金がない場合、一番少ない値=DateTime.new(1, 1, 1, 0, 0, 0)を最後の入金日にする
    last_deposited_at = self.payouts&.order(created_at: :desc)&.first&.created_at || DateTime.new(1, 1, 1, 0, 0, 0)
    Transaction.all
      .left_joins(:service)
      .where(service:{user: self}, is_transacted:true)
      .where("transacted_at > ?", last_deposited_at)
      .order(created_at: :ASC)
  end

  def total_points
    self.point_records.sum(:amount)
  end

  def total_points_from_transactions
    payments = self.payments.where(status: 'succeeded')

    total_transactions = Transaction
    .left_joins(:request)
    .where(
      buyer: self,
      is_canceled:false, 
      is_violating: false,
      is_rejected:false, 
      is_contracted:true,
      request:{
        is_published:true
      }
    )
    payments.sum(:point) - total_transactions.sum(:price)
  end

  def update_total_sales_numbers
    transactions = Transaction.left_joins(:service).where(service:{user:self}, is_transacted:true)
    self.update(total_sales_numbers: transactions.count)
  end
  
  def update_average_star_rating
    transactions = Transaction.left_joins(:service).where(service:{user:self}).where.not(star_rating: nil)
    self.update(average_star_rating: transactions.average(:star_rating).to_f)
  end

  def update_service_mini_price
    self.update(mini_price: Service.where(user: self, request_id: nil, is_published:true).minimum(:price))
  end

  def update_categories
    service_category_names = buyable_service_categories.pluck(:category_name)
    transaction_category_names = delivered_transaction_categories.pluck(:category_name)
    service_count_pairs = get_category_count_pairs(service_category_names)
    transaction_count_pairs = get_category_count_pairs(transaction_category_names)
    # 各単語の合計を計算
    combined = {}
    transaction_count_pairs.each do |hash|
      hash.each { |word, count| combined[word] = { transaction_count_pairs: count, service_count_pairs: 0 } }
    end

    service_count_pairs.each do |hash|
      hash.each { |word, count| combined[word] ||= { transaction_count_pairs: 0 }
                 combined[word][:service_count_pairs] = count }
    end
  
    #transaction_count_pairsを優先して、数の多い順に並べ替え
    category_names = combined.keys.sort_by do |word|
      [-combined[word][:transaction_count_pairs], -combined[word][:service_count_pairs]]
    end
    category_names.each do |name|
      user_category = self.user_categories.find_by(category_name: name)
      sleep 0.01
      if user_category
        user_category.update(updated_at: DateTime.now)
      else
        self.user_categories.create(category_name: name)
      end
    end
    self.user_categories.where.not(category_name: category_names).destroy_all
  end

  def get_category_count_pairs(category_names)
    category_names
      .tally.map { |word, count| { word => count } } #[{"business"=>2}, {"carrier"=>1}]のようにカテゴリー名とその数
      .sort_by { |hash| -hash.values.first }
  end

  def name_max_length
    return 15
  end

  def description_max_length
    return 1000
  end

  def is_stripe_account_valid?
    if self.stripe_account_id.present?
      begin
        stripe_account =  Stripe::Account.retrieve(self.stripe_account_id)
        if false#stripe_account.requirements.disabled_reason == "under_review"
          false
        else 
          stripe_account.payouts_enabled# && stripe_account.charges_enabled
        end
      rescue => e
        false
      end
    else
      false
    end
  end

  def is_stripe_customer_valid?
    if self.stripe_customer_id.nil? || self.stripe_card_id.nil?
      return false
    end
    begin
      stripe_account =  Stripe::Customer.retrieve_source(
        self.stripe_customer_id,
        self.stripe_card_id,
      )
      if ["pass","unavailable"].include?(stripe_account.cvc_check)
        true
      else
        false
      end
    rescue
      false
    end
  end

  def can_respond_order(request)
    #ログインしている
    transactions = request.transactions.left_joins(:service).where(
      is_contracted:true, 
      is_rejected: false,
      is_canceled: false,
      is_transacted: false,
      service:{user: self}
      )
    #特定のサービスの出品者である
    transaction = transactions.last
    if transaction.present? #契約中のサービスがある
        true
    else
        false
    end
  end

  def validate_registering_is_seller
    return unless will_save_change_to_is_seller? && !self.is_seller
    return unless self.sales.ongoing.present?
    errors.add(:base, "回答者登録を解除するには、回答待ちの取引を終了させる必要があります")
  end

  def validate_unregistering_is_seller
    return unless self.is_seller
    if will_save_change_to_is_seller? || will_save_change_to_description?
      if text_length(self.description) < mini_seller_description_length
        self.description = description_was
        errors.add(:base, "回答者登録するには100字以上の自己紹介が必要です")
      end
    end

    if will_save_change_to_is_seller? || will_save_change_to_image?
      if self.image.blank?
        errors.add(:base, "回答者登録するにはプロフィール画像が必要です")
      end
    end
  end

  def validate_is_published
    return unless !self.is_published && will_save_change_to_is_published?
    if  self.sales.ongoing.present?
      errors.add(:base, "非公開にするには、回答待ちの取引を終了させる必要があります")
    end
  end

  def self.selector_hash
    I18n.t('activerecord.attributes.user/state').invert
  end

  def max_service_price
    buyable_services.maximum(:price)
  end

  def mini_service_price
    buyable_services.minimum(:price)
  end

  def mini_seller_description_length
    100
  end
end
