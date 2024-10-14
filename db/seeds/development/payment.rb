customer_id = User.second.stripe_customer_id
card_id = User.second.stripe_card_id
charges = Stripe::Charge.search({
  query: "customer:'#{customer_id}'",
  limit: 100
})

charges.each do |charge|
    Payment.create(
        user:User.second,
        stripe_payment_id: charge.id, 
        stripe_customer_id: customer_id,
        stripe_card_id: card_id,
        price: charge.amount,
        point: charge.amount,
        status:"normal",
        is_succeeded:true,
        is_refunded:false
    )
end