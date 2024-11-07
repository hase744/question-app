class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  after_create :update_remaining_amount

  def update_remaining_amount
    self.coupon.save
  end
end
