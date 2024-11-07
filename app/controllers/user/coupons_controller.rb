class User::CouponsController < User::Base
  before_action :check_login
  before_action :define_coupon, only: [:show, :activate]
  layout "small"
  def show
  end

  def index
    @coupons = current_user.coupons
      .order(remaining_amount: :desc)
      .from_expiring_order
      .published
      .page(params[:page])
      .per(20)
  end

  def activate
    if @coupon.update(is_active: !@coupon.is_active)
      flash.alert = "クーポンを変更しました"
    else
      flash.alert = "クーポンを変更に失敗しました"
    end
    redirect_back(fallback_location: root_path)
  end

  private def define_coupon
    @coupon = current_user.coupons.find(params[:id])
  end
end
