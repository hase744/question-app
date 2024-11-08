class Coupon < ApplicationRecord
  belongs_to :user
  has_many :usages, class_name: "CouponUsage", dependent: :destroy
  has_many :transactions, through: :usages, source: :deal, dependent: :destroy
  enum usage_type: { unlimited: 0, one_time: 1 }
  before_validation :inactive_coupons
  before_validation :set_default_values
  validate :validate_usage_type
  validate :validate_amount
  validate :validate_minimum_purchase_amount
  validate :validate_is_active
  validate :validate_span

  scope :from_expiring_order, -> {
    order(end_at: :asc)
  }

  scope :valid, -> {
    where('start_at <= ?', DateTime.now)
    .where('end_at > ?', DateTime.now)
  }

  scope :published, -> {
    where('start_at <= ?', DateTime.now)
  }

  scope :expired, -> {
    where('end_at <= ?', DateTime.now)
  }

  scope :not_expired, -> {
    where('end_at > ?', DateTime.now)
  }

  scope :usable, -> (price = 0){
    where("start_at <= ? AND end_at >= ?", DateTime.now, DateTime.now)
    .where('minimum_purchase_amount <= ?', price)
    .where('remaining_amount > ?', 0)
    #.where("(
    #  (usage_type = ? AND amount - COALESCE((SELECT SUM(coupon_usages.amount) * coupons.discount_rate FROM coupon_usages WHERE coupon_usages.coupon_id = coupons.id), 0) > 0) OR
    #  (usage_type = ? AND NOT EXISTS (SELECT 1 FROM coupon_usages WHERE coupon_usages.coupon_id = coupons.id))
    #)", usage_types[:unlimited], usage_types[:one_time])
  }

  scope :solve_n_plus_1, -> {
    includes(:user)
  }

  def deactivate_all
    return unless self.is_active
    self.update_all(is_active: false)
  end

  def set_default_values
    self.remaining_amount = get_remaining_amount
  end

  def get_remaining_amount
    if self.usage_type == 'unlimited'
      self.amount - (self.usages&.sum(:amount)*self.discount_rate).to_i
    elsif self.usage_type == 'one_time'
      self.usages.present? ? 0 : self.amount
    end
  end

  def usable
    return false if start_at > DateTime.now
    return false if end_at < DateTime.now
    remaining_amount > 0
  end

  def self.selector_hash
    I18n.t('activerecord.attributes.coupon/usage_type').invert
  end

  def type_name_japanese
    I18n.t("activerecord.attributes.coupon/usage_type.#{usage_type}")
  end

  def validate_minimum_purchase_amount
    errors.add(:base, "金額は100円毎にしか設定できません") if self.minimum_purchase_amount % 100 != 0
  end

  def validate_amount
    if self.amount < self.minimum_purchase_amount && self.discount_rate < 1
      errors.add(:base, "割引率が100%未満の時、金額は最低購入金額より低く設定できません")
    end
    errors.add(:base, "金額は100円毎にしか設定できません") if self.amount % 100 != 0
  end

  def validate_usage_type
    case usage_type
    when "unlimited"
      errors.add(:base, "無制限の際は割引率は100%未満に設定できません") if discount_rate < 1
    when "one_time"
      #errors.add(base, "１度きりの際は割引率は100%に設定できません") if discount_rate >= 1
    end
  end

  def validate_is_active
    one_time_active_coupons = self.user.coupons.usable.where(is_active: true, usage_type: "one_time")
    if one_time_active_coupons.present? && self.is_active && will_save_change_to_is_active?
      errors.add(:base, "１度きりのクーポンは一つしか使用できません")
    end
  end

  def inactive_coupons
    return unless self.is_active && will_save_change_to_is_active?
    coupons_to_inactivate = self.user.coupons.valid
    coupons_to_inactivate = coupons_to_inactivate.where(usage_type: "one_time") if usage_type == "unlimited"
    coupons_to_inactivate.update_all(is_active: false)
  end

  def validate_span
    errors.add(:base, "公開時期より先に期限を設定できません") if self.start_at > self.end_at
  end
end
