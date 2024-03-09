class ServiceFile < ApplicationRecord
  belongs_to :service
  mount_uploader :file, FileUploader
  mount_uploader :thumbnail, FileUploader
end
