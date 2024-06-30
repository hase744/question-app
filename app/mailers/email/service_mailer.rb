class Email::ServiceMailer < ApplicationMailer
    def suggestion(transaction)
        request = transaction.request
        @service = transaction.service
        mail to: request.user.email, subject: "相談室提案の報告"
    end
end
