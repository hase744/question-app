class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  require_relative "country.rb"
  require_relative "form.rb"
  require_relative "category.rb"
  include CommonMethods
  include FormConfig
  include Variables
  include CommonConcern
  include TemplateConcern
  include OperationConfig
  include ItemConcern
  include ImageGenerator
  include CommonScopes

  scope :from_latest_order, ->() {
    order(created_at: :desc)
  }

  def self.sorted_by(order)
    case order
    when 'likes_count'
      sort_by_likes
    when 'due_date'
      due_soon
    when 'transactions_count'
      transactions_count
    when 'followers_count'
      sort_by_followers
    when 'suggestions_count'
      sort_by_suggestions
    when 'max_price'
      sort_by_max_price
    when 'price'
      sort_by_price
    when 'published_at'
      sort_by_published_at
    when 'deadline'
      sort_by_deadline
    else
      sort_by_default
    end
  end

  def self.acceptable_video_extensions
    extensions = FileUploader.new.extension_allowlist - ImageUploader.new.extension_allowlist
    extensions = extensions.map{|extension|
      "video/#{extension}"
    }.join(',')
  end

  def self.human_attribute_enum_value(attr_name, value)
    human_attribute_name("#{attr_name}.#{value}")
  end

  def human_attribute_enum(attr_name)
    self.class.human_attribute_enum_value(attr_name, self[attr_name])
  end

  def validate_price
    if self.price.nil?
      errors.add(:price)
    elsif self.price % 100 != 0
      errors.add(:price, "価格は100円ごとにしか設定できません")
    elsif self.price < 0
      errors.add(:price)
    end
  end

  #価格
  def price_minimum_number#最小値
    100
  end

  def price_max_number#最小値
    10000
  end

  def self.acceptable_image_extensions
    extensions =  ImageUploader.new.extension_allowlist
    extensions = extensions.map{|extension|
      "image/#{extension}"
    }.join(',')
  end

  def request_form_has_image?
    if ['text','image','free'].include?(request_form.name)
      true
    else
      false
    end
  end

  def delivery_form_has_image?
    if ['text','image','free'].include?(delivery_form.name)
      true
    else
      false
    end
  end

  def liked_class(user)
    if self.likes.where(user: user).present?
      "liked_button"
    else
      "not_liked_button"
    end
  end
end
