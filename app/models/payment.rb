class Payment < ApplicationRecord
  belongs_to :user
  validates :value, :point, :stripe_payment_id, :stripe_card_id, :stripe_customer_id, :status, presence: true
  before_validation :set_default_values
  after_save :create_record
  enum status: {
    canceled: 0,
    processing: 1,
    requires_action: 2,
    requires_capture: 3,
    requires_confirmation: 4,
    requires_payment_method: 5,
    succeeded: 6,
  }

  def set_default_values
    self.stripe_customer_id = self.user.stripe_customer_id
    self.stripe_card_id = self.user.stripe_card_id
    self.point ||= self.value
  end

  def point_options
    (100.. Request.new.max_price_upper_limit)
      .step(100)
      .map { |num| ["#{num}p", num] }
  end

  def create_record
    return unless saved_change_to_status?
    case status
    when "succeeded"
      PointRecord.create(
        user: self.user,
        payment: self,
        amount: self.value,
        type_name: 'charge',
        created_at: self.executed_at
      )
    end
  end
end
