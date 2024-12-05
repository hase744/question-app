FactoryBot.define do
  factory :request_category do
    category_name { "business" }
    request { association :request }
  end

  factory :request_category2, class: 'RequestCategory' do
    category_name { "career" }
  end
end