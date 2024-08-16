class ServiceItem < ApplicationRecord
  belongs_to :service, optional: true
  mount_uploader :file, FileUploader
  store_in_background :file
  attr_accessor :save_in_background
end
