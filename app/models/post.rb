class Post < ApplicationRecord
  belongs_to :user
  mount_uploader :file, ImageUploader
  validates :body, length: {maximum: :body_max_length}
  scope :solve_n_plus_1, -> {
    includes(:user)
  }
  def body_max_length
    500
  end
end
