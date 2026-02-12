class User::ChatServicesController < User::Base
  layout 'small'
  def new
    @chat_service = ChatService.new
  end

  def show
    @chat_service = ChatService.find(params[:id])
    @chat_transaction = ChatTransaction.new(
      chat_service: @chat_service,
      buyer: current_user,
      count: params[:count] || 1,
      price: @chat_service.price,
    )
    @chat_service.buyer = current_user
    @deficient_point = [@chat_transaction.required_points - current_user.total_points, 0].max
    @payment = Payment.new(point: @deficient_point || 100)
  end

  def create
    @chat_service = current_user.chat_services.new(service_params)
    if @chat_service.save
      flash.notice = '作成しました。'
      redirect_to user_account_path(current_user.id)
    else
      flash.notice = '作成できませんでした。' 
      render "user/chat_services/new"
    end
  end

  private def service_params
    params.require(:chat_service).permit(
      :price,
      :type_name,
      :limit
    )
  end
end
