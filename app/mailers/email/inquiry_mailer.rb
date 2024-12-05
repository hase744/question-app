class Email::InquiryMailer < ApplicationMailer
  def notify_admin_user(id)
    @inquiry = Inquiry.find(id)
    mail to: AdminUser.first.email, subject: "お問い合わせがありました"
  end

  def reply(inquiry)
    @inquiry = inquiry
    mail to: inquiry.email, subject: "お問い合わせ内容のお返事"
  end
end
