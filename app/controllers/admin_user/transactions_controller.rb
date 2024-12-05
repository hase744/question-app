class AdminUser::TransactionsController < AdminUser::Base
  def index
    @transactions = Transaction.from_latest_order
    @transactions = @transactions.where("transactions.title LIKE ?", "%#{params[:title]}%")
    @transactions = @transactions.where(id: User.find(params[:user_id]).sales.pluck(:id)) if params[:target] == 'sales'
    @transactions = @transactions.where(service_id: params[:service_id]) if params[:service_id]
    @transactions = @transactions.where(request_id: params[:request_id]) if params[:request_id]
    @transactions = @transactions.from_coupon(Coupon.find(params[:coupon_id])) if params[:coupon_id]
    @transactions = @transactions
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def update
    @transaction = Transaction.find(params[:id])
    @transaction.assign_attributes(transaction_params)
    if @transaction.is_disabled
      @announcement = Announcement.new(
        condition_type: 'individual',
        title: "取引無効のお知らせ",
        description: "お客様の取引が規約に違反したため、無効となりました。", 
        body: "#{@transaction.disable_reason}\r\n取引：<a href='/user/orders/#{@transaction.id}'>#{@transaction.title}</a>",
        published_at: DateTime.now,
      )
      @announcement.receipts.build(user: @transaction.seller)
      @announcement.receipts.build(user: @transaction.buyer)
    else
      flash.notice = "修正されませんでした"
      redirect_to admin_user_transaction_path(@transaction.id)
      return
    end
    ActiveRecord::Base.transaction do
	  	if @transaction.save && @transaction.destroy_all_coupons && @announcement.save
	  		flash.notice = "修正しました"
	  		redirect_to admin_user_transaction_path(@transaction.id)
      else
        render action: "edit"
      end
    end
  end

  def transaction_params
    params.require(:transaction).permit(
      :is_disabled,
      :disable_reason,
    )
  end
end
