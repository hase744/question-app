class ServiceItem < ApplicationRecord
  belongs_to :service, optional: true
  delegate :user, to: :service
  mount_uploader :file, FileUploader
  store_in_background :file
  after_save :update_item_src
  attr_accessor :save_in_background

  def thumb_with_default
    return "/updating_normal_size.jpg" if self.file_processing
    self.file&.thumb&.url.presence || "/corretech_icon.png"
  end
end
