class Payouts::UpdateJob < ApplicationJob
  queue_as :default

  def perform(user)
    payout_models = user.payouts
    if user.stripe_account_id
      payouts = Stripe::Payout.list({
        limit: 100, # 取得する送金記録の数を指定（例：10件）
        #status: 'in_transit'
        }, {
          stripe_account: user.stripe_account_id # ConnectアカウントIDを指定
        }
      )
      payouts.each do |payout|
        payout_model = payout_models.find { |p| p.stripe_payout_id == payout.id }
        if payout_model.present? && payout_model&.status_name != payout.status
          payout_model.update(status_name: payout.status) 
        end
      end
    end
  end
end
