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
        mail to: @transaction.buyer.email, subject: "あなたの購入がキャンセルされました"
    end

    def reject(transaction)
        @transaction = transaction
        mail to: @transaction.seller.email, subject: "あなたの質問がお断りされました"
    end

    def purchase(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "あなたの相談室に質問がされました"
    end

    def deliver(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "あなたの質問に回答が納品されました"
    end

    def inquire(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "あなたの相談室に購入前の確認の問い合がされました"
    end
end
