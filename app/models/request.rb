class Request < ApplicationRecord
  #include ActiveModel::Model
  #extend CarrierWave::Mount
  belongs_to :user
  belongs_to :service, optional: true
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  belongs_to :request_form, class_name: 'Form', foreign_key: :request_form_id
  belongs_to :delivery_form, class_name: 'Form', foreign_key: :delivery_form_id
  has_many :transactions
  has_many :services, through: :transactions
  has_many :items, class_name: "RequestItem", dependent: :destroy
  has_many :request_categories, class_name: "RequestCategory", dependent: :destroy
  has_many :categories,through: :request_categories, dependent: :destroy

  before_validation :set_default_values
  after_save :create_request_category
  
  attr_accessor :delivery_days
  attr_accessor :validate_published
  attr_accessor :category_id
  attr_accessor :video_second
  attr_accessor :use_youtube
  attr_accessor :youtube_id
  attr_accessor :file
  attr_accessor :thumbnail
  attr_accessor :request_file
  attr_accessor :service_id
  attr_accessor :service

  validates :title,:description, presence: true
  validates :title, length: {maximum: :title_max_length}
  validates :description, length: {maximum: :description_max_length}
  validates :max_price, numericality: {only_integer: true, greater_than_or_equal_to: 100, allow_nil: true}
  validate :validate_max_price
  validate :validate_title
  validate :validate_description
  validate :validate_delivery_days
  validate :validate_suggestion_deadline
  validate :validate_is_published
  #validate :validate_request_item #itemのdurationを取得できないため使用中断

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

    if original_request_exists?
      self.delivery_days = nil
    end
  end

  def category
    self.categories.first
  end

  def set_publish
    self.assign_attributes(
      is_published:true, 
      published_at:DateTime.now
      )
  end

  def set_default_values
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
      self.thumbnail = self.file
      self.youtube_id = nil
      self.use_youtube = false
      self.total_files = 0
    when "image" then
      self.thumbnail = self.file
      self.youtube_id = nil
      self.use_youtube = false
      self.total_files = 0
    when "video" then
      if self.use_youtube
        self.thumbnail = nil
      else
        self.youtube_id = nil
      end
      self.total_files = 1
    end

    if self.delivery_days
      self.suggestion_deadline = DateTime.now + self.delivery_days.to_i
    end
  end

  def set_service_values
    if self.service_id
      self.service = Service.find(self.service_id)
    end

    if self.service
      self.request_form = self.service.request_form
      self.delivery_form = self.service.delivery_form
      self.category_id = self.service.category.id
      self.suggestion_deadline = nil
    end
  end

  def set_item_values
    if self.items.present?
      self.request_file = self.items.first
      self.file = self.request_file.file
      self.thumbnail = self.request_file.thumbnail
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
        #&& !self.service.request.present?
        puts self.description.gsub(/(\r\n?|\n)/,"")
        puts self.description.gsub(/(\r\n?|\n)/,"").length
        errors.add(:description, "は最大#{self.service.request_max_characters}字です")
      end
    end
  end

  def validate_request_item
    puts "変化"
    puts self.will_save_change_to_is_published?
    puts will_save_change_to_is_published?
    if self.is_published && will_save_change_to_is_published?
      if self.items
        puts "時間"
        self.items.first.file_duration = self.file_duration
        puts self.items.first.file_duration
        if !self.items.first.valid?
          self.items.first.save
          errors.add(:items, "が不適切です")
        end
      else
        errors.add(:items, "がありません")
      end
    end
  end

  def validate_is_published
    if  self.is_published && !self.items.present?
      errors.add(:requested_item)
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
    if self.delivery_days
      errors.add(:delivery_days, "は30日以内に設定して下さい") if self.delivery_days.to_i > 30
      errors.add(:delivery_days, "は1日以上に設定して下さい") if self.delivery_days.to_i < 1
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
