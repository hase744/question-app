class Email::TransactionMailer < ApplicationMailer
    def notify_message(transaction_message)
        @url = "#{ENV['PROTOCOL']}://#{ENV['HOST']}/"
        @transaction_message = transaction_message

        if @transaction_message.deal.seller == @transaction_message.sender 
            @subject = "回答が届きました"
        else
            @subject = "質問が届きました"
        end

        mail to: transaction_message.receiver.email, subject: @subject
    end

    def cancel(transaction)
        @transaction = transaction
        mail to: @transaction.buyer.email, subject: "相談室の購入がキャンセルされました"
    end

    def reject(transaction)
        @transaction = transaction
        mail to: @transaction.seller.email, subject: "相談がお断りされました"
    end

    def purchase(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "相談室に質問が届きました"
    end

    def deliver(transaction)
        @transaction = transaction
        mail to: transaction.seller.email, subject: "相談に回答が届きました"
    end

    def inquire(transaction_message)
        @transaction_message = transaction_message
        @transaction = transaction_message.deal
        if transaction_message.sender == @transaction.seller
            message = "相談室に購入前質問がされました。"
        elsif transaction_message.sender == @transaction.buyer
            message = "購入前質問に返信がされました。"
        end
        puts "送信　#{transaction_message.receiver.email} #{message}"
        mail to: transaction_message.receiver.email, subject: message
    end
end
