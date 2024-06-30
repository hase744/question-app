class Request < ApplicationRecord
  #include ActiveModel::Model
  #extend CarrierWave::Mount
  belongs_to :user
  belongs_to :service, optional: true
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  has_many :transactions
  has_many :services, through: :transactions
  has_many :items, class_name: "RequestItem", dependent: :destroy
  has_many :request_categories, class_name: "RequestCategory", dependent: :destroy
  has_many :categories, through: :request_categories, dependent: :destroy
  has_one :request_category, dependent: :destroy
  has_one :category, through: :request_category

  before_validation :set_default_values
  after_save :create_request_category
  
  attr_accessor :delivery_days
  attr_accessor :validate_published
  attr_accessor :category_id
  attr_accessor :video_second
  attr_accessor :use_youtube
  attr_accessor :youtube_id
  attr_accessor :file
  attr_accessor :request_file
  attr_accessor :service_id
  attr_accessor :service

  validates :title, :description, presence: true
  validates :title, length: {maximum: :title_max_length}
  validates :description, length: {maximum: :description_max_length}
  validates :max_price, numericality: {only_integer: true, greater_than_or_equal_to: 100, allow_nil: true}
  validate :validate_max_price
  validate :validate_title
  validate :validate_description
  validate :validate_delivery_days
  validate :validate_suggestion_deadline
  validate :validate_is_published
  #validate :validate_request_item #itemのdurationを取得できないため使用中断enum state: CommonConcern.user_states
  enum request_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  enum delivery_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  accepts_nested_attributes_for :items, allow_destroy: true

  scope :solve_n_plus_1, -> {
    includes(:user, :services, :request_categories, :categories, :items)
  }

  scope :suggestable, -> {
    solve_n_plus_1
    .left_joins(:request_categories, :user)
    .where(
      is_published: true, 
      is_inclusive: true, 
      user:{
        is_published: true, 
        state: 'normal'
      }
    )
  }

  after_initialize do
    if self.service_id
      if Service.exists?(id: self.service_id) && !service.present?
        self.service = Service.find(self.service_id)
      end
    end

    if self.service
      self.service_id = self.service.id
    end

    if self.suggestion_deadline
      self.delivery_days ||= ((self.suggestion_deadline - Time.current)/60/60/24).round(0)
    end

    if self.suggestion_acceptance_duration
      self.suggestion_deadline ||= DateTime.now + suggestion_acceptance_duration
    end

    if original_request_exists?
      self.delivery_days = nil
    end

    self.request_form_name ||= Form.all.first.name
    self.delivery_form_name ||= Form.all.first.name
    set_request_content
  end

  def category
    self.categories.first
  end

  def request_form
    Form.find_by(name: self.request_form_name)
  end

  def delivery_form
      Form.find_by(name: self.delivery_form_name)
  end

  def acceptance_duration_in_days
    suggestion_acceptance_duration / 86400
  end

  # 日数を秒数に変換して acceptance_duration に設定
  def acceptance_duration_in_days=(days)
    self.suggestion_acceptance_duration = (days.to_f * 86400).to_i
  end
  
  def set_publish
    self.assign_attributes(
      is_published:true, 
      published_at:DateTime.now
      )
  end

  def set_default_values
    puts "セットアイテム : #{self.items&.first&.valid?}"
    if self.service
      #self.request_form = self.service.request_form
      #self.delivery_form = self.service.delivery_form
      #self.category_id = self.service.category.id
      #self.suggestion_deadline = DateTime.now + self.service.delivery_days.to_i
      case self.use_youtube #use_youtubeのbinaryの値をtrue/falseに変換
      when "1" then
        self.use_youtube = true
      when "0" then
        self.use_youtube = false
      end
    end
    
    case self.request_form.name
    when "text" then
      self.youtube_id = nil
      self.use_youtube = false
      self.total_files = 0
    when "image" then
      self.youtube_id = nil
      self.use_youtube = false
      self.total_files = 0
    when "video" then
      if self.use_youtube
      else
        self.youtube_id = nil
      end
      self.total_files = 1
    end


    if self.delivery_days
      self.acceptance_duration_in_days=(delivery_days)
      self.suggestion_deadline = DateTime.now + self.delivery_days.to_i
    end
  end

  def save_file_content(file_content)
    puts file_content == nil
    self.image = CarrierWave::Uploader::Base.new
    self.image.cache!(CarrierWave::SanitizedFile.new(StringIO.new(file_content)))
    self.image.retrieve_from_cache!(self.image.cache_name)
    self.save
  end

  def is_suggestable?(user)
    if get_unsuggestable_message(user).present?
      false
    else
      true
    end
  end

  def get_unsuggestable_message(user)
    if !self.is_inclusive
      "その質問には提案できません"
    elsif self.user == user
      "自分の質問には提案できません"
    elsif  self.suggestion_deadline < DateTime.now
      "期限が過ぎています"
    else
      nil
    end
  end

  def set_service_values
    if self.service_id
      self.service = Service.find(self.service_id)
    end

    if self.service
      self.request_form_name = self.service.request_form_name
      self.delivery_form_name = self.service.delivery_form_name
      self.category_id = self.service.category.id
      self.suggestion_deadline = nil
    end
  end

  def set_item_values
    if self.items.present?
      self.request_file = self.items.first
      self.file = self.request_file.file
      self.use_youtube = self.request_file.use_youtube
      self.youtube_id = self.request_file.youtube_id
    else
      #self.request_file = self.items.new()
    end
  end

  def save_length
    if self.request_form.name == "text"
    elsif self.request_form.name == "image"
      self.length = 1
    elsif self.request_form.name == "video"
      self.length = video_second
    end
  end

  def create_request_category
    if self.service
      self.service.categories.each do |category|
        if !RequestCategory.exists?(request: self, category: category)
          self.request_categories.create(category: category)
        end
      end
    else
      if self.request_categories.first
          self.request_categories.first.update(category_id: category_id)
      else
          self.request_categories.create(category_id: category_id)
      end
    end
  end
  
  def validate_max_price
    if max_price
      errors.add(:max_price, "は100円ごとにしか設定できません") if max_price % 100 != 0
      errors.add(:max_price, "は100円以上に設定して下さい") if max_price < 100
      errors.add(:max_price, "は10000円以下に設定して下さい") if max_price_upper_limit < max_price
    end
  end

  def validate_category
    if !self.categories.exists? && !Category.exists?(id: self.category_id)
        #カテゴリーが存在しない & 入力されたカテゴリーが存在しない
        errors.add(:category_id)
    end
  end

  def validate_suggestion_deadline
    #公開依頼である
    if self.is_inclusive && !self.suggestion_deadline.present?
      errors.add(:suggestion_deadline)
    end
  end

  def validate_title
    if self.title.present?
      errors.add(:title, "を入力して下さい") if self.title.length <= 0 #&& self.validate_published
    else
      errors.add(:title, "を入力して下さい") if self.validate_published
    end
  end

  def validate_description
    if self.description.present?
      errors.add(:description, "を入力して下さい") if self.description.length <= 0 #&& self.validate_published
    else
      errors.add(:description, "を入力して下さい") if self.validate_published
    end

    if self.service
      if self.service.request_max_characters && self.service.request_max_characters < self.description.gsub(/(\r\n?|\n)/,"a").length
        errors.add(:description, "は最大#{self.service.request_max_characters}字です")
      end
    end
  end

  def validate_request_item
    if self.is_published && will_save_change_to_is_published?
      if self.items
        self.items.first.file_duration = self.file_duration
        if !self.items.first.valid?
          self.items.first.save
          puts "だめ #{self.items.first.valid?}"
          errors.add(:items, "が不適切です")
        end
      else
        errors.add(:items, "がありません")
      end
    end
  end

  def validate_is_published
    if  self.is_published && !self.items.present?
      errors.add(:items)
    end
  end
  
  def validate_request_form
    if self.service
      errors.add(:request_form, "が違います") if self.service.request_form != self.request_form
    end
  end

  def validate_delivery_form
    if self.service
      errors.add(:delivery_form, "が違います") if self.service.delivery_form != self.delivery_form
    end
  end

  def validate_delivery_days
    if self.delivery_days && self.will_save_change_to_suggestion_acceptance_duration?
      errors.add(:delivery_days, "は30日以内に設定して下さい") if self.acceptance_duration_in_days > 30
      errors.add(:delivery_days, "は1日以上に設定して下さい") if self.acceptance_duration_in_days < 1
    end
  end

  def title_max_length
    30
  end

  def original_request_exists?
    if self.service
      self.service.request.present?
    else
      false
    end
  end

  def image_display_style
    if self.service&.request_form&.name == 'image' 
      'block'
    else
      'none'
    end
  end

  def video_display_style
    if self.service&.request_form&.name == 'video' 
      'block'
    else
      'none'
    end
  end

  def description_max_length
    20000
  end

  def max_price_upper_limit
    10000
  end

  def delivery_days_upper_limit
    30
  end
end
