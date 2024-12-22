class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :deal, class_name: 'Transaction', optional: true, foreign_key: :transaction_id
  belongs_to :request, optional: true
  validate :validate_deal_request
  after_create :update_remaining_amount

  def update_remaining_amount
    self.coupon.save
  end

  def validate_deal_request
    errors.add(:base, 'request_idとtransaction_idが空です。') if self.deal.blank? && self.request.blank?
  end
end
