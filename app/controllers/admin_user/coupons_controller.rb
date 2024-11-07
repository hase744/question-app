class AdminUser::CouponsController < AdminUser::Base
  def show
    @coupon = Coupon.find(params[:id])
  end

  def index
    @coupons = Coupon.all
      .page(params[:page])
      .per(50)
  end

  def new
    @coupon = Coupon.new()
    @coupon.assign_attributes(coupon_params) if params[:coupon]
    @users = User
			.where("users.name LIKE ?", "%#{params[:name]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

  def create
    @coupon = Coupon.new(coupon_params)
    if @coupon.save
			flash.notice = "作成しました"
			redirect_to admin_user_coupon_path(@coupon.id)
    else
      @users = User
			  .where("users.name LIKE ?", "%#{params[:name]}%")
			  .from_latest_order
			  .page(params[:page])
			  .per(50)
      render action: "new"
    end
  end

  def edit
    @coupon = Coupon.find(params[:id])
    @coupon.assign_attributes(coupon_params) if params[:coupon]
    @users = User
			.where("users.name LIKE ?", "%#{params[:name]}%")
			.from_latest_order
			.page(params[:page])
			.per(50)
  end

	def update
    @coupon = Coupon.find(params[:id])
		if @coupon.update(coupon_params)
			flash.notice = "更新しました"
			redirect_to admin_user_coupon_path(@coupon.id)
    else
      @users = User
        .where("users.name LIKE ?", "%#{params[:name]}%")
        .from_latest_order
        .page(params[:page])
        .per(50)
        render action: "edit"
    end
	end

  def coupon_params
    params.require(:coupon).permit(
      :user_id,
      :amount,
      :discount_rate,
      :start_at,
      :end_at,
      :minimum_purchase_amount,
      :usage_type,
    )
  end
end
