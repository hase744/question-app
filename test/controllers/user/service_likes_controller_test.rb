require "test_helper"

class User::ServiceLikesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get user_service_likes_create_url
    assert_response :success
  end

  test "should get delete" do
    get user_service_likes_delete_url
    assert_response :success
  end
end
