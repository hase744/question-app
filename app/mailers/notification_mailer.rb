class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.transaction.subject
  #
  def transaction(transaction)
    @transaction = transaction

    mail to: transaction.seller.email
  end
end
