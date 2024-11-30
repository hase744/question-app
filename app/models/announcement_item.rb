class AnnouncementItem < ApplicationRecord
  belongs_to :announcement
  mount_uploader :file, FileUploader
  store_in_background :file

  def thumb_with_default
    self.file&.thumb&.url.presence || "/corretech_icon.png"
  end
end