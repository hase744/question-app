# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/transaction
  def transaction
    NotificationMailer.transaction
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/message
  def message
    NotificationMailer.message
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/service
  def service
    NotificationMailer.service
  end

end
