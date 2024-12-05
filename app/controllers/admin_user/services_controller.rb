class AdminUser::ServicesController < AdminUser::Base
  def index
    @services = Service.from_latest_order
    @services = @services.where("services.title LIKE ?", "%#{params[:title]}%")
    @services = @services.where(user_id: params[:user_id]) if params[:user_id]
    @services = @services
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @service = Service.find(params[:id])
  end

  def edit
    @service = Service.find(params[:id])
  end

  def update
    @service = Service.find(params[:id])
    @service.assign_attributes(service_params)
    if @service.is_disabled
      @ongoing_transactions = @service.transactions.ongoing
      @announcement = Announcement.new(
        condition_type: 'individual',
        title: "相談室が無効になったことのお知らせ",
        description: "相談室が規約に違反したため、無効となりました。\r\nそれに従い、進行中の取引は全て無効となります。", 
        body: "#{@service.disable_reason}\r\n相談室：<a href='/user/services/#{@service.id}'>#{@service.title}</a>",
        published_at: DateTime.now,
      )
      @announcement.receipts.build(user: @service.user)
      User.where(id: @ongoing_transactions.select(:buyer_id).distinct).each do |buyer|
        @announcement.receipts.build(user: buyer)
      end
      @ongoing_transactions = @ongoing_transactions.map do |transaction|
        transaction.tap do |t|
          t.is_disabled = true
          t.disable_reason = "相談室が規約に違反したため、無効になりました"
        end
      end
    else
      flash.notice = "修正されませんでした"
      redirect_to admin_user_service_path(@service.id)
      return
    end
    ActiveRecord::Base.transaction do
	  	if @ongoing_transactions.all?(&:save) && 
      @service.save && 
      @ongoing_transactions.all?(&:save) && 
      @ongoing_transactions.all?(&:destroy_all_coupons) && 
      @announcement.save
	  		flash.notice = "修正しました"
	  		redirect_to admin_user_service_path(@service.id)
      else
        render action: "edit"
      end
    end
  end

  private def service_params
    params.require(:service).permit(
      :is_disabled,
      :disable_reason,
    )
  end
end