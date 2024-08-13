class ServiceItem < ApplicationRecord
  belongs_to :request, optional: true
  mount_uploader :file, FileUploader
end
