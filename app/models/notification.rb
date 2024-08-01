class Notification < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: :user_id
  belongs_to :notifier, class_name: "User", foreign_key: :notifier_id, optional: true

  scope :solve_n_plus_1, -> {
    includes(:user, :notifier)
  }
end
