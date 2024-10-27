class User::PrePurchaseInquiriesController < User::Base
  before_action :check_login
  layout 'small'
  #before_action :define_transaction, only:[:create]
  def index
    @transactions = Transaction.solve_n_plus_1
      .by(current_user)
      .where.not(pre_purchase_inquired_at:nil)
      .left_joins(:transaction_messages)
      .group('transactions.id')
      .order(Arel.sql("CASE WHEN transactions.id = #{params[:transaction_id].to_i} THEN 0 ELSE 1 END, MAX(transaction_messages.created_at) DESC"))
      .page(params[:page]).per(20)
  end

  def create
    @transaction_message = TransactionMessage.new(transaction_message_params)
    @transaction = @transaction_message.deal
    @transaction_message.sender = current_user
    @transaction_message.receiver = @transaction.opponent_of(current_user)
    @transaction.pre_purchase_inquired_at ||= DateTime.now
    ActiveRecord::Base.transaction do
      if @transaction_message.save && @transaction.save
        message = if current_user == @transaction.seller
          "購入前質問に返信がされました。"
        elsif current_user == @transaction.buyer
          "購入前質問がされました。"
        end
        EmailJob.perform_later(mode: :inquire, model: @transaction_message) if @transaction_message.receiver.can_email_transaction
        Notification.create(
          user: @transaction.opponent_of(current_user),
          notifier_id: current_user.id,
          title: message,
          description: @transaction_message.body,
          action: "index",
          controller: "pre_purchase_inquiries",
          parameter: "?transaction_id=#{@transaction.id}",
          )
        puts "OK"
        render json: { message: "送信しました", status: "success" }, status: :ok
      else
        render json: { message: "送信できませんでした", errors: @transaction_message.errors.full_messages, status: "error" }, status: :unprocessable_entity
      end
    end
  end

  private def define_transaction
    @transaction = Transaction.find(params[:id])
  end

  private def transaction_message_params
    params.require(:transaction_message).permit(
      :transaction_id,
      :body,
      :file
    )
  end
end
