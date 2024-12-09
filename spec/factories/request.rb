FactoryBot.define do
  factory :request do
    title { "Sample Request" }
    description { "This is a description for the sample request." }
    max_price { 1000 }
    suggestion_acceptable_days { 3 }
    is_published { false }
    is_inclusive { true }
    suggestion_deadline { DateTime.now + 10 }
    user { association :user }
    request_form_name { Form.find_by(name: 'text').name_sym }
    delivery_form_name { Form.find_by(name: 'text').name_sym }
  
    after(:build) do |request|
      request.request_categories << build(:request_category, request: request)
    end

    trait :without_service do
      service { nil }
    end

    trait :existing do
      after(:create) do |request|
      end
    end

    trait :with_item do
      after(:create) do |request|
        item = request.build_item
        item.assign_attributes(attributes_for(:request_text_item))
      end
    end

    trait :published do
      after(:create) do |request|
        request.set_publish
        request.save
      end
    end
  end

  factory :published_request do
    title { "Sample Request" }
    description { "This is a description for the sample request." }
    max_price { 1000 }
    suggestion_acceptable_days { 3 }
    is_published { true }
    published_at { DateTime.now }
    is_inclusive { true }
    suggestion_deadline { DateTime.now + 10 }
    user { association :user }
    request_form_name { Form.find_by(name: 'text').name_sym }
    delivery_form_name { Form.find_by(name: 'text').name_sym }
  
    after(:build) do |request|
      request.request_categories << build(:request_category, request: request)
    end

    trait :without_service do
      service { nil }
    end

    trait :existing do
      after(:create) do |request|
      end
    end

    trait :with_item do
      after(:create) do |request|
        item = request.build_item
        item.assign_attributes(attributes_for(:request_text_item))
      end
    end

    trait :published do
      after(:create) do |request|
        request.set_publish
        request.save
      end
    end
  end

  factory :exclusive_request, class: "Request" do
    title { "Sample Request" }
    description { "This is a description for the sample request." }
    max_price { 1000 }
    suggestion_acceptable_days { 3 }
    is_published { false }
    user { association :user }
    is_inclusive { false }
    request_form_name { Form.find_by(name: 'text').name_sym }
    delivery_form_name { Form.find_by(name: 'text').name_sym }

    after(:build) do |request|
      request.request_categories << build(:request_category, request: request)
    end

    trait :without_service do
      service { nil }
    end

    trait :existing do
      after(:create) do |request|
      end
    end

    trait :with_item do
      after(:create) do |request|
        item = request.build_item
        item.assign_attributes(attributes_for(:request_text_item))
      end
    end

    trait :published do
      after(:create) do |request|
        request.set_publish
        request.save
      end
    end
  end
end
