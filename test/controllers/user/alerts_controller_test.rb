require "test_helper"

class User::AlertsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_alerts_index_url
    assert_response :success
  end
end
