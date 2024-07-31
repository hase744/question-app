class User::TransactionMessagesController < User::Base
  before_action :check_user, only:[:create]
  def cells
    begin
      @transaction_messages = TransactionMessage
        .by_transaction_id_and_order(
          transaction_id: params[:transaction_id], 
          order: params[:transaction_message_order],
          page: params[:page],
          after_delivered: params[:after_delivered] == 'true' || params[:after_delivered] == true
          )
      if @transaction_messages.last == Transaction.last
        @is_last_cell = true
      else
        @is_last_cell = false
      end
      render partial: 'user/transaction_messages/cell', collection: @transaction_messages, as: :content
    end
  end

  def reset_cells
    @transaction_messages = TransactionMessage
      .by_transaction_id_and_order(
        transaction_id: params[:transaction_id], 
        order: params[:transaction_message_order],
        page: 1,
        after_delivered: params[:after_delivered] == 'true' || params[:after_delivered] == true
        )
  end

  def create
    @transaction_message = TransactionMessage.new(transaction_message_params)
    @transaction_message.sender = current_user
    @transaction = @transaction_message.deal
    if @transaction_message.save
      EmailJob.perform_later(mode: :message, model: @transaction_message)
      if @transaction.seller == @transaction_message.sender
        create_notification(@transaction.buyer, "追加回答が届いています。")
        flash.alert = "回答を送信しました。"
      else
        create_notification(@transaction.seller, "追加質問が届いています。")
        flash.alert = "質問を送信しました。"
      end
      if @transaction.is_delivered
        redirect_to user_transaction_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
      else
        redirect_to user_transaction_message_room_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
      end
    else
      flash.notice = "投稿できませんでした。#{@transaction_message.errors.full_messages}"
      if @transaction.is_delivered
        redirect_to user_transaction_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
      else
        redirect_to user_transaction_message_room_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
      end
    end
  end

  def create_notification(user, description)
    if @transaction.is_delivered
      action = "show"
    else
      action = "messages"
    end
    Notification.create(
      user:user,
      notifier_id: current_user.id,
      controller: "transactions",
      action: action,
      id_number:@transaction.id,
      description: description,
      parameter: "?transaction_message_order=DESC"
    )
  end

  private def check_user
    if !user_signed_in?
      redirect_to new_user_session_path
    end
  end
  
  private def identify_user
    request = TransactionMessage.find(params[:id])
    if request.user != current_user
      redirect_to user_requests_path
    end
  end
    
  private def transaction_message_params
    params.require(:transaction_message).permit(
      :transaction_id,
      :body,
      :file
    )
  end
end
