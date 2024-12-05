class ErrorLog < ApplicationRecord
  belongs_to :user, optional: true
  validates :uuid, uniqueness: true
  before_create -> { self.uuid = "er_#{SecureRandom.uuid}" }
end
