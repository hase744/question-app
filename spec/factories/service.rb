FactoryBot.define do
  factory :service do
    title { "Sample Service" }
    description { "This is a description for the sample service." }
    price { 1000 }
    delivery_days { 3 }
    is_published { true }
    is_for_sale { true }
    mode { 'proposal' }
    allow_pre_purchase_inquiry { true }
    user { association :user2 }
    request_form_name { Form.find_by(name: 'text').name_sym }
    delivery_form_name { Form.find_by(name: 'text').name_sym }

    after(:build) do |service|
      service.service_categories << build(:service_category, service: service)
    end

    trait :existing do
      after(:create) do |service|
      end
    end
  end
end
