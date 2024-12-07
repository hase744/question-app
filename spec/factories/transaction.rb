FactoryBot.define do
  factory :transaction do
    title { "Sample Transaction" }
    description { "This is a description for the sample transaction." }
    request {association :exclusive_request, :with_item}
    service {association :service}

    trait :contracted do
      before(:build) do |transaction|
        create(:payment_1000, user: transaction.request.user)
        transaction.request.set_publish
        transaction.set_contraction
      end
    end
  end
end
