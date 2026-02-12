module Couponable
  extend ActiveSupport::Concern

  included do
    has_many :coupon_usages, as: :couponable
  end

  def required_points
    coupon_model = appropriate_coupons
    puts "トータル #{total_price}"
    return total_price if coupon_model.nil?
    if coupon_model.is_a?(Coupon) # 単体クーポンの場合
      total_price - ([coupon_model.remaining_amount, total_price].min * coupon_model.discount_rate).to_i
    else # unlimitedクーポンの場合
      total_price - [total_price, coupon_model.to_a.sum(&:remaining_amount)].min
    end
  end

  def build_coupon_usages
    coupon_model = appropriate_coupons
    return if coupon_model.nil?
    if coupon_model.is_a?(Coupon) # 単体クーポンの場合
      coupon_usages.build(amount: [coupon_model.remaining_amount, total_price].min * coupon_model.discount_rate, coupon: coupon_model)
    else # unlimitedクーポンの場合
      discounted_price = total_price
      coupon_model.each do |coupon|
        break if discounted_price.zero?
        amount_to_discount = [discounted_price, coupon.remaining_amount].min
        coupon_usages.build(amount: amount_to_discount, coupon: coupon)
        discounted_price -= amount_to_discount
      end
    end
  end

  def destroy_all_coupons
    return true if coupon_usages.blank?
    response = coupon_usages.respond_to?(:destroy_all)
    if response
      coupon_ids = coupons.pluck(:id)
      coupon_usages.destroy_all
      Coupon.where(id: coupon_ids).each(&:save)
    else
      errors.add(:coupon_usages, "クーポンに関するエラー")
    end
    response
  end

  def appropriate_coupons
    unless coupon_user.use_inactive_coupon
      active_coupons = coupon_user.coupons.usable(total_price).where(is_active: true)
      return active_coupons.first if active_coupons.count == 1
      return active_coupons if active_coupons
    end
    latest_coupon = get_latest_coupon
    if latest_coupon&.usage_type == 'one_time'
      latest_coupon
    elsif latest_coupon&.usage_type == 'unlimited'
      unlimited_coupons
    else
      nil
    end
  end

  def get_latest_coupon
    coupon_user.coupons.usable(total_price).order(end_at: :asc).first
  end

  def unlimited_coupons
    unlimitd_coupons = coupon_user.coupons.usable(total_price).where(usage_type: 'unlimited').order(end_at: :asc)
    selected_coupon_ids = []
    sum = 0
    unlimitd_coupons.each do |coupon|
      selected_coupon_ids << coupon
      sum += coupon.remaining_amount
      break if sum >= total_price
    end
    unlimitd_coupons.where(id: selected_coupon_ids)
  end

  # 子クラスに実装が必要なメソッド
  def total_price
    raise NotImplementedError, "子クラスで `total_price` を定義してください"
  end

  def coupon_user
    raise NotImplementedError, "子クラスで `coupon_user` を定義してください"
  end
end
