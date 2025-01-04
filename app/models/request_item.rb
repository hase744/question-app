class RequestItem < ApplicationRecord
  belongs_to :request, optional: true #optional: trueじゃないとbuildできない
  delegate :is_published, to: :request
  delegate :user, to: :request
  attr_accessor :use_youtube
  attr_accessor :service
  attr_accessor :file_duration
  attr_accessor :duration
  mount_uploader :file, FileUploader
  store_in_background :file
  after_save :update_item_src
  validate :validate_file

  scope :not_text_image, -> {
    where(is_text_image: false)
  }

  scope :text_image, -> {
    where(is_text_image: true)
  }

  after_initialize do
    if self.youtube_id.present?
      self.use_youtube = true
    else
      self.use_youtube = false
    end
    if !self.file_processing && self.file.url
      self.delete_temp_file 
    end
  end

  def request_form
    self.request.request_form
  end

  def assign_image_from_content(html_content, css_content)
    generated_image_url = generate_image_from_content(html_content, css_content) + '.png'
    downloaded_file = download_file_from_url(generated_image_url)
    self.file = downloaded_file
    self.is_text_image = true
  end

  #process_file_upload=trueにするとfileとfile_tmpはnilになるがなぜか保存できるためアップロード後にvalidation
  def validate_file
    return unless self.is_published
    case self.request_form.name
    when "text"
      errors.add(:file, "ファイルをアップロードして下さい") unless self.file.present?
      errors.add(:file, "アップロードできるのは文章のみです") unless self.file.is_image?
      errors.add(:file, "アップロードできるのは文章のみです") unless self.is_text_image
    when "image"
      errors.add(:file, "ファイルをアップロードして下さい") unless self.file.present?
      errors.add(:file, "アップロードできるのは画像のみです") unless self.file.is_image?
    end
  end

  def thumb_with_default
    self.file&.thumb&.url.presence || "/corretech_icon.png"
  end
end
