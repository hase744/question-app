class Payment < ApplicationRecord
  belongs_to :user
  validates :price, :point, :stripe_payment_id, :stripe_card_id, :stripe_customer_id, :status, presence: true
  before_validation :set_default_values
  after_save :update_user_point

  def set_default_values
    puts Payment.all.count
    self.stripe_customer_id = self.user.stripe_customer_id
    self.stripe_card_id = self.user.stripe_card_id
    self.point ||= self.price
  end

  def update_user_point
    self.user.update_total_points
  end
end
