class Post < ApplicationRecord
  belongs_to :user
  mount_uploader :file, ImageUploader
  validates :body, length: {maximum: :body_max_length}
  def body_max_length
    500
  end
end
