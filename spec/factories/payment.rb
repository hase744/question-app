FactoryBot.define do
  factory :payment_1000, class: 'Payment' do
    user { association :user }
    stripe_payment_id { "ch_abc" }
    stripe_card_id { "card_abc" }
    stripe_customer_id { "cus_abc" }
    status { "succeeded" }
    value { 1000 }
    point { 1000 }
    executed_at { DateTime.now }
  end
end