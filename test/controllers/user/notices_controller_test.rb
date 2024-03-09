require "test_helper"

class User::NoticesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_notices_index_url
    assert_response :success
  end
end
