FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }
    is_seller { true }
    name { "user name" } # 必要であれば追加
  end
end
