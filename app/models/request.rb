class Request < ApplicationRecord
  #include ActiveModel::Model
  #extend CarrierWave::Mount
  belongs_to :user
  belongs_to :service, optional: true
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  has_many :transactions, dependent: :destroy
  has_many :services, through: :transactions
  has_many :items, class_name: "RequestItem", dependent: :destroy
  has_many :request_categories, class_name: "RequestCategory", dependent: :destroy
  has_many :supplements, class_name: "RequestSupplement", dependent: :destroy
  has_one :request_category, dependent: :destroy
  delegate :category, to: :request_category, allow_nil: true
  has_many :likes, class_name: "RequestLike"

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
  #validates :max_price, numericality: {greater_than_or_equal_to: 100}
  validate :validate_title
  validate :validate_description
  validate :validate_delivery_days
  validate :validate_suggestion_deadline
  validate :validate_is_published
  validate :validate_request_category
  validate :validate_max_price
  validate :validate_request_item #itemのdurationを取得できないため使用中断enum state: CommonConcern.user_states
  validate :validate_can_stop_accepting
  validate :validate_item_count
  enum request_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  enum delivery_form_name: Form.all.map{|c| c.name.to_sym}, _prefix: true
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :request_categories, allow_destroy: true

  scope :solve_n_plus_1, -> {
    includes(:user, :services, :request_categories, :items)
  }

  scope :suggestable, -> {
    solve_n_plus_1
    .left_joins(:request_categories, :user)
    .where(
      is_accepting: true,
      is_published: true, 
      is_inclusive: true, 
      user:{
        is_published: true, 
        state: 'normal'
      }
    )
  }

  scope :from_service, ->(service){
    self.left_joins(:services).where(services: service, is_published: true)
  }

  scope :filter_categories, -> (names){
    if names.present?
      names = names.split(',')
      self.left_joins(:request_categories)
        .where(request_categories: {
          category_name: names
        })
    else
      self
    end
  }

  scope :sort_by_default, -> {
    order(published_at: :DESC)
  }

  scope :sort_by_likes, -> {
    left_joins(:likes)
      .group('requests.id')
      .order('COUNT(request_likes.id) DESC')
  }

  scope :sort_by_published_at, -> {
    order(published_at: :DESC)
  }

  scope :sort_by_max_price, -> {
    order(max_price: :DESC)
  }

  scope :sort_by_deadline, -> {
    where("suggestion_deadline > ?", DateTime.now)
    .order(suggestion_deadline: :ASC)
  }

  scope :sort_by_likes, -> {
    left_joins(:likes)
      .group('requests.id')
      .order('COUNT(request_likes.id) DESC')
  }

  scope :sort_by_suggestions, -> {
    left_joins(:transactions)
      .select('requests.*, COUNT(CASE WHEN transactions.is_suggestion = true THEN 1 END) AS suggested_transactions_count')
      .group('requests.id')
      .order('suggested_transactions_count ASC')
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

    if self.suggestion_acceptable_duration
      self.delivery_days ||= self.suggestion_acceptable_duration/1.day.to_i
    end

    if self.delivery_days
      self.suggestion_acceptable_duration ||= self.delivery_days*1.day.to_i
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

  def categories
    Category.where(name:self.request_categories.pluck(:category_name))
  end

  def request_form
    Form.find_by(name: self.request_form_name)
  end

  def delivery_form
    Form.find_by(name: self.delivery_form_name)
  end

  def transaction
    return nil if self.is_published
    return nil if self.transactions.count > 1
    transactions.first
  end

  def total_likes
    self.likes.count
  end

  def thumb_with_default
    self.items&.first&.file&.thumb&.url.presence || "/corretech_icon.png"
  end

  def acceptable_duration_in_days
    suggestion_acceptable_duration / 1.day.to_i
  end

  # 日数を秒数に変換して acceptable_duration に設定
  def acceptable_duration_in_days=(days)
    self.suggestion_acceptable_duration = (days.to_f * 1.day.to_i).to_i
  end
  
  def set_publish
    self.assign_attributes(
      is_published:true, 
      published_at:DateTime.now
      )
  end

  def is_suppliable
    if !self.is_published
      false
    elsif !self.is_inclusive
      false
    elsif self.supplements.present?
      false
    elsif !self.is_suggestable?
      false
    else
      true
    end
  end

  def set_default_values
    update_category
    copy_from_service if new_record?

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
      self.acceptable_duration_in_days=(delivery_days)
    end

    if self.is_inclusive && self.is_published
      #self.suggestion_deadline = DateTime.now + self.delivery_days.to_i
    end
  end

  def save_file_content(file_content)
    self.image = CarrierWave::Uploader::Base.new
    self.image.cache!(CarrierWave::SanitizedFile.new(StringIO.new(file_content)))
    self.image.retrieve_from_cache!(self.image.cache_name)
    self.save
  end

  def is_suggestable?(user=nil)
    if get_unsuggestable_message(user).present?
      false
    else
      true
    end
  end

  def can_stop_accepting?
    if !self.is_accepting
      false
    elsif !self.is_inclusive
      false
    else
      true
    end
  end

  def update_category #カテゴリのアップデートは既存のrequest_categoryのcategory_nameをアップデートして新規のデータは生成しない
    if self.request_categories.length > 1
      if self.categories.length > 1 #カテゴリの種類がたくさんある
        self.request_categories.first.update(
          category_name: self.request_categories.last.category_name
        )
      end
      self.request_categories.last.destroy
    end
  end

  def get_unsuggestable_message(user=nil)
    if !self.is_inclusive
      "その質問には提案できません"
    elsif self.user == user
      "自分の質問には提案できません"
    elsif  self.suggestion_deadline < DateTime.now
      "期限が過ぎています"
    elsif !self.is_accepting
      "取り下げられました。"
    else
      nil
    end
  end

  def copy_from_service
    self.service = Service.find(self.service_id) if self.service_id
    return if self.service.nil?
    request_category_names = self.request_categories.pluck(:category_name)
    service_category_names = self.service.service_categories.pluck(:category_name)
    service_category_names.each do |name|
      unless request_category_names.include?(name)
        self.request_categories.new(category_name: name)
      end
    end
    request_category_names.each do |name|
      unless service_category_names.include?(name)
        self.request_categories.find_by(category_name: name).destroy
      end
    end
    self.request_form_name = self.service.request_form_name
    self.delivery_form_name = self.service.delivery_form_name
    self.category_id = self.service.category.id
    self.suggestion_deadline = nil
  end

  def set_service_values
    self.service = Service.find(self.service_id) if self.service_id
    return if self.service.nil?
    self.request_form_name = self.service.request_form_name
    self.delivery_form_name = self.service.delivery_form_name
    self.category_id = self.service.category.id
    self.suggestion_deadline = nil
  end

  def main_link
		if self.is_published
			user_request_path(self.id)
    else
			transaction_id = self.transactions&.last&.id
			user_request_preview_path(self.id, transaction_id: transaction_id)
		end
  end

  def status
    if self.is_inclusive
      if  self.suggestion_deadline && self.suggestion_deadline < DateTime.now
        "期限切れ"
      elsif !self.is_accepting
        "取り下げ"
      else
        "受付中"
      end
    else
      transactions = Transaction.where(request_id: self.id)
      if transactions.length >= 1 
        transaction = transactions[0]
        if transaction.is_canceled || transaction.is_rejected
          "中断"
        elsif transaction.is_transacted
          "回答済み"
        else
          "回答待ち"
        end
      else
        "回答待ち"
      end
    end
  end
  
  def status_color
    if self.is_inclusive
      if  self.suggestion_deadline && self.suggestion_deadline < DateTime.now || !self.is_accepting
        'grey'
      else
        "green"
      end
    else
      transactions = Transaction.where(request_id: self.id)
      if transactions.length >= 1 
        transaction = transactions[0]
        if transaction.is_canceled || transaction.is_rejected
          "grey"
        elsif transaction.is_transacted
          "green"
        else
          "orange"
        end
      else
        "orange"
      end
    end
  end

  def validate_request_category
    unless self.request_categories.present?
      errors.add(:base, 'カテゴリーが選択されていません')
      throw(:abort)
    end

    if self.request_categories.count > 1
      errors.add(:base)
      throw(:abort)
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
        if !RequestCategory.exists?(request: self, category_name: category.name)
          self.request_categories.create(category_name: category.name)
        end
      end
    else
      if self.request_categories.first
          #self.request_categories.first.update(category_id: category_id)
      else
          #self.request_categories.create(category_id: category_id)
      end
    end
  end

  def need_text_image?
    self.request_form.name == "text" || (self.request_form.name == "free" && self.items.not_text_image.count < 1)
  end

  def validate_item_count
    return if self.items.count <= self.max_items_count
    return unless self.will_save_change_to_is_published?
    return unless self.is_published
    errors.add(:items, "の数は#{self.max_items_count}個までです")
  end
  
  def validate_max_price
    if will_save_change_to_max_price? || (self.service.nil? && new_record?)
      errors.add(:max_price, "を設定してください") if max_price.nil?
    end
    if self.max_price.present?
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
    if self.is_inclusive && !self.suggestion_deadline.present? && self.is_published
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

    #新規の作成 or 作成後に相談室の最大文字数が変更され、最大文字数がひっかかった場合
    if self.service && (new_record? || self.is_published && will_save_change_to_is_published?)
      if self.service.request_max_characters && self.service.request_max_characters < self.description.gsub(/(\r\n?|\n)/,"a").length
        over_character_count = self.description.gsub(/(\r\n?|\n)/,"a").length - self.service.request_max_characters
        errors.add(:description, "文字数を#{self.service.request_max_characters}字以下にしてください。（#{over_character_count}字オーバー）")
      end
    end
  end

  def validate_request_item
    return unless self.is_published && will_save_change_to_is_published?
    case request_form.name
    when 'text'
      errors.add(:items, "が不適切で") if self.items.text_image.count != 1
    when 'image'
      errors.add(:items, "をアップロードしてください") if self.items.not_text_image.count < 1
    end
    self.items.each do |item|
      unless item.valid?
        item.errors.full_messages.each do |message|
          errors.add(:items, "が不適切です。 #{message}")
        end
      end
    end
    if self.items
      #self.items.first.file_duration = self.file_duration
    else
      errors.add(:items, "がありません")
    end
  end

  def validate_is_published
    if  self.is_published
      errors.add(:items, "が処理中です") unless all_items_processed?
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
    if self.delivery_days && self.will_save_change_to_suggestion_acceptable_duration?
      errors.add(:delivery_days, "は30日以内に設定して下さい") if self.acceptable_duration_in_days > 30
      errors.add(:delivery_days, "は1日以上に設定して下さい") if self.acceptable_duration_in_days < 1
    end
  end

  def validate_can_stop_accepting
    return if self.is_accepting
    return if self.will_save_change_to_is_accepting?
    return unless self.is_published
    errors.add(:base, "取り下げに失敗しました")
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

  def file_field_display_style
    if self.service&.request_form&.name == 'text'
      'none'
    else
      'block'
    end
  end

  def file_label_display_style
    if self.items.where(is_text_image: false).present?
      'block'
    elsif self.service&.request_form&.name == 'text'
      'none'
    else
      'block'
    end
  end

  def video_display_style
    if self.service&.request_form&.name == 'video' 
      'block'
    else
      'none'
    end
  end

  def description_max_length(service=nil)
    if service
      service.request_max_characters
    else
      20000
    end
  end

  def max_price_upper_limit
    10000
  end

  def delivery_days_upper_limit
    30
  end

  def max_items_count
    10
  end
end
