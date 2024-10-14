stripe_account_id = User.first.stripe_account_id
payouts = Stripe::Payout.list({
  limit: 100, # 取得する送金記録の数を指定（例：10件）
}, {
  stripe_account: stripe_account_id # ConnectアカウントIDを指定
})
payouts.each do |payout|
  Payout.create(
    user: User.first,
    stripe_account_id: stripe_account_id,
    stripe_payout_id: payout.id,
    status_name: payout.status,
    amount: payout.amount,
    created_at: Time.at(payout.created).to_datetime,
    fee: 200,
    total_deduction: payout.amount + 200,
  )
end