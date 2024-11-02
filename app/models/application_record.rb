class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  require_relative "country.rb"
  require_relative "form.rb"
  require_relative "category.rb"
  self.abstract_class = true
  include CommonMethods
  include FormConfig
  include Variables
  include CommonConcern
  include TemplateConcern
  include OperationConfig


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

  def last_item
    items.order(created_at: :asc).last
  end

  def validate_price
    if self.price.nil?
      errors.add(:price)
    elsif self.price % 100 != 0
      errors.add(:price, "は100円ごとにしか設定できません")
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

  def resave
    original_tmp_path = Rails.root.to_s + "/public/uploads/tmp/" + self.file_tmp
    original_tmp_path_array = original_tmp_path.split('/')
    original_tmp_path_array.pop
    original_tmp_foloder_path = original_tmp_path_array.join('/')
    file = File.open(original_tmp_path)
    if File.exist?(original_tmp_path) && File.exist?(original_tmp_foloder_path)
      self.process_file_upload = true
      self.file = file
      self.file_tmp = nil
      self.file_processing = true
      self.save
      delete_folder(original_tmp_foloder_path)
    end
  end

  def delete_folder(path)
    if File.exist?(path) && path.include?('/tmp/')
      FileUtils.rm_rf(path)
      Rails.logger.info "Folder #{path} deleted successfully due to save failure"
    else
      Rails.logger.warn "File #{path} not found"
    end
  end

  def all_items_processed?
    self.items
      .where(file_processing: true)
      .or(self.items.where(file: nil))
      .empty?
  end
end
