require "test_helper"

class User::PrePurchaseInquiriesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_pre_purchase_inquiries_show_url
    assert_response :success
  end
end
