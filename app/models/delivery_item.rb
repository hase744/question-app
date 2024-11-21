class DeliveryItem < ApplicationRecord
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
  delegate :user, to: :deal
  attr_accessor :use_youtube
  attr_accessor :video_second
  mount_uploader :file, FileUploader
  store_in_background :file
  validate :validate_youtube_id
  validate :validate_file
  before_validation :set_default_values
  after_save :update_item_src
  
  after_initialize do
    if self.youtube_id.present?
      self.use_youtube = true
    else
      self.use_youtube = false
    end
  end
  
  def delivery_form
    self.deal.delivery_form
  end
  
  def set_default_values
    case self.use_youtube
    when "1" then
      self.use_youtube = true
    when "0" then
      self.use_youtube = false
    end
  
    case delivery_form.name
    when "text" then
      self.youtube_id = nil
    when "image" then
      self.youtube_id = nil
    when "video" then
      if self.use_youtube
        self.file = nil
      else
        self.youtube_id = nil
      end
    end
  end
  
  def service
    self.deal.service
  end
  
  def is_published
    self.deal.is_published
  end
  
  def validate_youtube_id
    if self.will_save_change_to_youtube_id?
      if  self.delivery_form.name == "text"
        errors.add(:youtube_id, "YouTubeのIDが適切ではありません") if self.youtube_id != nil
      elsif self.delivery_form.name == "image"
        errors.add(:youtube_id, "YouTubeのIDが適切ではありません") if self.youtube_id != nil
      elsif self.delivery_form.name == "video"
        if self.use_youtube
          if !is_youtube_id_valid? #&& self.validate_published
            errors.add(:youtube_id, "YouTubeのIDが適切ではありません")
          end
        else
          errors.add(:youtube_id, "YouTubeのIDが適切ではありません") if self.youtube_id != nil
        end
      end
    end
  end
  
  def validate_file
    return unless self.is_published
    if  self.delivery_form.name == "text"
      errors.add(:file, "ファイルをアップロードして下さい") if !self.file.present? #&& self.validate_published
      #errors.add(:file, "のフォーマットが正しくありません") if !is_image_extension #&& self.validate_published
    elsif self.delivery_form.name == "image"
      errors.add(:file, "ファイルをアップロードして下さい") if !self.file.present? #&& self.validate_published
    elsif self.delivery_form.name == "video"
      if !self.use_youtube
        errors.add(:file, "のフォーマットが正しくありません") if !is_video_extension #&& self.validate_published
        errors.add(:file, "ファイルをアップロードして下さい") if !self.file.present? #&& self.validate_published
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
  
  def is_image_extension
    if self.file.present?
      file_extension = File.extname(self.file.path).delete(".")
      if ImageUploader.new.extension_allowlist.include?(file_extension)
        true
      else
        false
      end
    else
      false
    end
  end
  
  private def is_youtube_id_valid?
    if self.use_youtube
      begin
        require 'google/apis/youtube_v3'
        youtube = Google::Apis::YoutubeV3::YouTubeService.new
        youtube.key = ENV["YOUTUBE_V3_KEY"]
  
        response = youtube.list_videos("contentDetails", id:self.youtube_id)
        response.items[0].content_details.duration.present?
      rescue
        false
      end
    else
      true
    end
  end
end
