class Payout < ApplicationRecord
  belongs_to :user
  enum status_name: { paid: 0, pending: 1, in_transit: 2, canceled: 3, failed: 4 }
end
