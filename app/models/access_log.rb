class AccessLog < ApplicationRecord
  belongs_to :user, dependent: :destroy
end
