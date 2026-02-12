class User::ChatTransactionsController < User::Base
  before_action :check_login
  before_action :check_budget_sufficient, only: [:create]
  layout 'small'
  def show
    @chat_transaction = current_user.purchased_chat_transactions.find(params[:id])
  end

  def index
    @chat_transactions = current_user.purchased_chat_transactions.order(created_at: :desc)
  end

  def create
    @transaction = ChatTransaction.new(chat_transaction_params)
    @transaction.buyer = current_user
    @transaction.state = 'transacted'
    @transaction.transacted_at = DateTime.now
    destination = current_user.chat_destinations.find_by(target: @transaction.seller)
    @transaction.chat_destination = destination
    if @transaction.save
      flash.notice = '購入しました'
      redirect_to user_chat_destinations_path(uuid: @transaction.chat_service.user.uuid)
    else
      flash.notice = '購入できませんでした'
      redirect_to user_chat_services_path(count: params[:ccount])
    end
  end

  private def check_budget_sufficient
    @transaction = ChatTransaction.new(chat_transaction_params)
    @transaction.buyer = current_user
    @transaction.copy_chat_service
    @service = @transaction.chat_service
    return if @service.nil? 
    return if current_user.total_points >= @transaction.required_points
    @defficiency = @transaction.required_points - current_user.total_points
    flash.notice = "残高が#{@defficiency}ポイント不足しています"
    redirect_to(params[:return_to])
  end

  private def chat_transaction_params
    params.require(:chat_transaction).permit(
      :count,
      :chat_service_id,
      :count,
    )
  end
end
