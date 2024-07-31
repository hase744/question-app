class EmailJob < ApplicationJob
  queue_as :default

  def perform(params)
    mode = params[:mode]
    model = params[:model]
    case mode
    when :purchase
      Email::TransactionMailer.purchase(model).deliver_now
    when :deliver
      Email::TransactionMailer.deliver(model).deliver_now
    when :cancel
      Email::TransactionMailer.cancel(model).deliver_now
    when :reject
      Email::TransactionMailer.reject(model).deliver_now
    when :message
      Email::TransactionMailer.notify_message(model).deliver_now
    end
  end
end
