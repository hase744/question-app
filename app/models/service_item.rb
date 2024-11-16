class ServiceItem < ApplicationRecord
  belongs_to :service, optional: true
  delegate :user, to: :service
  mount_uploader :file, FileUploader
  store_in_background :file
  after_save :update_item_src
  attr_accessor :save_in_background
end
