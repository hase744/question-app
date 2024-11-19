FactoryBot.define do
  factory :service_category do
    category_name { "business" }
    service { association :service }
  end
end