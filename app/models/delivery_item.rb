class DeliveryItem < ApplicationRecord
  belongs_to :deal, class_name: "Transaction", foreign_key: :transaction_id
  delegate :user, to: :deal
  attr_accessor :use_youtube
  attr_accessor :video_second
  mount_uploader :file, FileUploader
  store_in_background :file
  validate :validate_file
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
  
  def service
    self.deal.service
  end
  
  def is_published
    self.deal.is_published
  end
  
  def validate_file
    return unless self.is_published
    case self.delivery_form.name
    when 'text'
      errors.add(:file, "ファイルをアップロードして下さい") if !self.file.present?
    when 'image'
      errors.add(:file, "ファイルをアップロードして下さい") if !self.file.present?
    end
  end
end
