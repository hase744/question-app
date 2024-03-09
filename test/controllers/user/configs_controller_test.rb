require "test_helper"

class User::ConfigsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_configs_index_url
    assert_response :success
  end
end
