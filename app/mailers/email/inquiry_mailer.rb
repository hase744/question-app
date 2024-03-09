class Email::InquiryMailer < ApplicationMailer
    def notify_amin_user(id)
        @inquiry = Inquiry.find(id)
        mail to: AdminUser.first.email, subject: "お問い合わせがありました"
    end
end
