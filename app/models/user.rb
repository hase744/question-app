class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  mount_uploader :image, ImageUploader
  mount_uploader :header_image, ImageUploader

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
  has_many :relationships, class_name: "Relationship", foreign_key: :followee_id, dependent: :destroy
  has_many :relationships, class_name: "Relationship", foreign_key: :follower_id, dependent: :destroy
  has_many :requests, class_name: "Request", foreign_key: :user_id, dependent: :destroy
  has_many :services, class_name: "Service", foreign_key: :user_id, dependent: :destroy
  has_many :users, class_name: "User", foreign_key: :user_id, dependent: :destroy
  #has_many :categories, class_name: "UserCategory", dependent: :destroy
  has_many :user_categories, class_name: "UserCategory", dependent: :destroy
  has_many :service_categories, through: :services, source: :service_categories
  has_many :deals, class_name: "Transaction", foreign_key: :user_id
  has_many :transaction_likes, class_name: "TransactionLike", foreign_key: :user_id
  has_many :payments, dependent: :destroy
  has_many :historyies, dependent: :destroy, class_name: "UserStateHistory", foreign_key: :user_id
  #has_many :transactions, through: :service
  
  validates :name, length: {maximum:15, minimum:1}
  validates :description, length: {maximum: :description_max_length}
  validate :validate_is_published
  validate :validate_is_seller
  
  before_validation :set_default_values
  after_commit :create_user_state_hitrory

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
  attr_accessor :bank_number
  attr_accessor :branch_number
  attr_accessor :account_number
  attr_accessor :account_holder_name
  attr_accessor :is_female
  attr_accessor :is_male
  attr_accessor :gender
  attr_accessor :is_dammy
  enum country_id: Country.all.map{|c| c.name.to_sym}
  enum state: CommonConcern.user_states

  scope :solve_n_plus_1, -> {
    includes(:service_categories)
  }
  
  scope :is_sellable, -> {
    left_joins(:user_categories)
    .solve_n_plus_1
    .where(
      is_published: true, 
      is_seller: true,
      state: 'normal'
      )
  }

  scope :filter_categories, -> (names){
    if names.present?
      names = names.split(',')
      self.left_joins(:service_categories)
      .where(service_categories: {
        category_name: names
      }).distinct
    else
      self
    end
  }

  def country
    Country.find_by(name: self.country_id)
  end

  def self.categories
    Category.all.select do |category|
      user_categories.any? { |uc| uc.category_name == category.name }
    end
  end

  def categories
    Category.where(name:self.service_categories.pluck(:category_name))
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

  def update_total_points
    total_charged_points = 0
    Payment.where(user:self).each do |payment|
      total_charged_points += payment.point
    end
    total_transactions = Transaction.left_joins(:request)
    total_transactions = total_transactions.where(
      buyer: self,
      is_canceled:false, 
      is_violating: false,
      is_rejected:false, 
      is_contracted:true,
      request:{
        is_published:true
      }
    )
    total_charged_points -= total_transactions.sum(:price)
    self.total_points = total_charged_points
    self.save
  end

  def update_total_sales_numbers
    transactions = Transaction.left_joins(:service).where(service:{user:self}, is_delivered:true)
    self.update(total_sales_numbers: transactions.count)
  end
  
  def update_average_star_rating
    transactions = Transaction.left_joins(:service).where(service:{user:self}).where.not(star_rating: nil)
    self.update(average_star_rating: transactions.average(:star_rating).to_f)
  end

  def update_total_reviews
    transactions = Transaction.left_joins(:service).where(service:{user:self}).where.not(star_rating: nil)
    self.update(total_reviews: transactions.count)
  end
  
  def update_service_mini_price
    self.update(mini_price: Service.where(user: self, request_id: nil, is_published:true).minimum(:price))
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
        is_delivered: false,
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

  def validate_is_seller
    puts "出品者登録変更 #{will_save_change_to_is_seller?}"
    if will_save_change_to_is_seller? && is_dammy == false
      if self.is_seller && !is_stripe_account_valid?
        errors.add(:is_seller, "登録をできません")
      elsif !self.is_seller && ongoing_transaction_exist?
        errors.add(:is_seller, "登録を解除できません。取引を全て終わらせてください。")
      end
    end
  end

  def ongoing_transaction_exist?
    exist = false
    Transaction.where(seller:self ,is_delivered:false, is_canceled:false).each do |transaction|
      if !transaction.is_rejected
        exist = true
        break
      end
    end
    return exist
  end

  def validate_is_published
    if  !self.is_published
      ongoing_transactions = Transaction.where(seller: self, is_delivered:false).or(Transaction.where(buyer: self, is_delivered:false))
      if ongoing_transactions.count > 0 #取引中の依頼がああるか
        errors.add(:is_published)
      end
    end
  end
end
