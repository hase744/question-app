FactoryBot.define do
  factory :request_text_item, class: 'RequestItem' do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.jpg'), 'image/jpeg') }
    #request { association :request }
    process_file_upload { false }
    file_processing { false }
    is_text_image { true }
  end

  factory :request_item do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.jpg'), 'image/jpeg') }
    #request { association :request }
    request { nil }
  end
end
