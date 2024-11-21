FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    stripe_customer_id { "cus_example" }
    stripe_card_id { "card_example" }
    confirmed_at { Date.today }
    is_seller { false }
    name { "user name" } # 必要であれば追加
  end

  factory :user2, class: 'User' do
    sequence(:email) { |n| "user2#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Date.today }
    is_seller { true }
    name { "user name" } # 必要であれば追加
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.jpg'), 'image/jpeg') }
    description { "This is a description for a test. It serves as a placeholder to simulate a real-world introduction or data input scenario in various testing environments. The purpose is to ensure that the application can handle text fields correctly, including validating character limits and formatting." }
  end
end
