require "test_helper"

class User::InquiriesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_inquiries_new_url
    assert_response :success
  end

  test "should get create" do
    get user_inquiries_create_url
    assert_response :success
  end
end
