class AdminUser::RequestsController < AdminUser::Base
  def index
    @requests = Request.from_latest_order
    @requests = @requests.where("requests.title LIKE ?", "%#{params[:title]}%")
    @requests = @requests.where(user_id: params[:user_id]) if params[:user_id]
    @requests = @requests
      .from_latest_order
      .page(params[:page])
      .per(50)
  end

  def show
    @request = Request.find(params[:id])
  end

  def edit
    @request = Request.find(params[:id])
  end

  def update
    @request = Request.find(params[:id])
    @request.assign_attributes(request_params)
    if @request.is_disabled
      @ongoing_transactions = @request.transactions.not_transacted
      @announcement = Announcement.new(
        condition_type: 'individual',
        title: "質問が無効になったことのお知らせ",
        description: "質問が規約に違反したため、無効となりました。\r\nそれに従い、進行中の取引は全て無効となります。", 
        body: "#{@request.disable_reason}\r\n質問：<a href='/user/requests/#{@request.id}'>#{@request.title}</a>",
        published_at: DateTime.now,
      )
      @announcement.receipts.build(user: @request.user)
      User.where(id: @ongoing_transactions.select(:seller_id).distinct).each do |seller|
        @announcement.receipts.build(user: seller)
      end
      @ongoing_transactions = @ongoing_transactions.map do |transaction|
        transaction.tap do |t|
          t.is_disabled = true
          t.disable_reason = "相談室が規約に違反したため、無効になりました"
        end
      end
    else
      flash.notice = "修正されませんでした"
      redirect_to admin_user_request_path(@request.id)
      return
    end
    ActiveRecord::Base.transaction do
	  	if @request.save && 
      @ongoing_transactions.all?(&:save) && 
      @ongoing_transactions.all?(&:destroy_all_coupons) && 
      @announcement.save
	  		flash.notice = "修正しました"
	  		redirect_to admin_user_request_path(@request.id)
      else
        render action: "edit"
      end
    end
  end

  private def request_params
    params.require(:request).permit(
      :is_disabled,
      :disable_reason,
    )
  end
end
