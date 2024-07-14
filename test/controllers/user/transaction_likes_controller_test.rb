require "test_helper"

class User::TransactionLikesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_transaction_likes_show_url
    assert_response :success
  end
end
