class Email::TransactionMailer < ApplicationMailer
    def notify_message(transaction_message)
        @url = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/"
        @transaction_message = transaction_message

        if @transaction_message.deal.seller == @transaction_message.sender 
            @subject = "回答が届きました"
        else
            @subject = "質問が届いています"
        end

        mail to: transaction_message.receiver.email, subject: @subject
    end

    def cancel(transaction)
        @transaction = transaction
        mail to: @transaction.buyer.email, subject: "あなたのサービスの依頼がキャンセルされました"
    end

    def rejection(transaction)
        @transaction = transaction
        mail to: @transaction.seller.email, subject: "あなたの依頼がお断りされました"
    end

    def purchase(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "あなたのサービスが購入されました"
    end

    def delivery(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "あなたの依頼に回答が納品されました"
    end
end
