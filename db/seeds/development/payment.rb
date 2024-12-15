customer_id = User.second&.stripe_customer_id
return unless customer_id
card_id = User.second.stripe_card_id
charges = Stripe::PaymentIntent.search({
  query: "customer:'#{customer_id}'",
  limit: 100
})

charges.each do |charge|
  puts Payment.create!(
    user: User.second,
    executed_at: Time.at(charge.created).to_datetime,
    stripe_payment_id: charge.id, 
    stripe_customer_id: customer_id,
    stripe_card_id: card_id,
    value: charge.amount,
    point: charge.amount,
    status: charge.status,
    is_succeeded: true,
    is_refunded: false
  )
end