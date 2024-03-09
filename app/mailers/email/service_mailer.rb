class Email::ServiceMailer < ApplicationMailer
    def suggestion(service)
        @service = service
        request = Request.find(@service.request_id)
        mail to: request.user.email, subject: "サービス提案の報告"
    end
end
