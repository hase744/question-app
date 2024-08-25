class Relationship < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :target_user, class_name: 'User'

  enum type_name: { follow: 0, block: 1 }

  validates :type_name, presence: true

  scope :follow, -> {
    where(type_name: "follow")
  }
end
