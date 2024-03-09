class User::TransactionMessagesController < User::Base
    before_action :check_user, only:[:create]
    def cells
        begin
            @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:transaction_id]).page(params[:page]).order(created_at: params[:transaction_message_order]).per(5)
            if @transaction_messages.last == Transaction.last
                @is_last_cell = true
            else
                @is_last_cell = false
            end
            render partial:  "user/transaction_messages/cells", locals: {transaction_messages:@transaction_messages}
        end
    end

    def reset_cells
        @transaction_messages = TransactionMessage.includes(:sender).where(transaction_id:params[:transaction_id]).order(created_at: params[:transaction_message_order]).limit(5)
    end

    def create
        @transaction_message = TransactionMessage.new(transaction_message_params)
        @transaction_message.sender = current_user
        @transaction = @transaction_message.deal
        if @transaction_message.save
            Email::TransactionMailer.notify_message(@transaction_message).deliver_now #if @transaction_message.receiver.can_email_transaction
            if @transaction.seller == @transaction_message.sender
                create_notification(@transaction.buyer, "追加回答が届いています。")
                flash.notice = "回答を送信しました。"
            else
                create_notification(@transaction.seller, "追加質問が届いています。")
                flash.notice = "質問を送信しました。"
            end
            redirect_to user_transaction_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
        else
            flash.notice = "送信できませんでした。"
            begin
                redirect_to user_transaction_path(id: params[:transaction_message][:transaction_id], transaction_message_order:"DESC")
            rescue
                redirect_to user_transactions_path
            end
        end
    end

    def create_notification(user, description)
        Notification.create(
            user:user,
            notifier_id: current_user.id,
            controller:"transactions",
            action:"show",
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
