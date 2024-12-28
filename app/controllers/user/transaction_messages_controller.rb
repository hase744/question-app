class User::TransactionMessagesController < User::Base
  before_action :check_user, only:[:create]
  before_action :define_transaction_message, only:[:cells, :reset_cells]
  def cells
    begin
      render partial: 'user/transaction_messages/cell', collection: @transaction_messages, as: :content
    end
  end

  def reset_cells
  end

  def create
    @transaction_message = TransactionMessage.new
    @transaction_message.process_file_upload = true
    @transaction_message.sender = current_user
    @transaction_message.assign_attributes(transaction_message_params)
    @transaction = @transaction_message.deal
    redirect_url = URI.parse(request.referer || root_path)
    query_params = Rack::Utils.parse_nested_query(redirect_url.query)
    query_params.delete("open_message_modal")
    redirect_url.query = query_params.to_query
    
    if @transaction_message.save
      EmailJob.perform_later(mode: :message, model: @transaction_message) if @transaction_message.receiver.can_email_transaction
      if @transaction.seller == @transaction_message.sender
        create_notification(@transaction.buyer, "メッセージが届いています")
      else
        create_notification(@transaction.seller, "メッセージが届いています")
      end
      flash.alert = "メッセージを送信しました。"
      redirect_to redirect_url.to_s, fallback_location: root_path(transaction_message_order: "DESC")
    else
      flash.notice = "投稿できませんでした。#{@transaction_message.errors_messages}"
      redirect_to redirect_url.to_s, fallback_location: root_path(transaction_message_order: "DESC")
    end
  end

  def create_notification(user, title)
    if @transaction.is_transacted
      action = "show"
    else
      action = "messages"
    end
    Notification.create(
      user: user,
      notifier_id: current_user.id,
      published_at: DateTime.now,
      controller: "transactions",
      action: action,
      id_number: @transaction.id,
      title: title,
      description: @transaction_message.body,
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
      :receiver_id,
      :body,
      :file
    )
  end
end
