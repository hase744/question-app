require "test_helper"

class User::ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get user_reviews_update_url
    assert_response :success
  end

  test "should get destroy" do
    get user_reviews_destroy_url
    assert_response :success
  end
end
