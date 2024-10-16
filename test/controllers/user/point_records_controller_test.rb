require "test_helper"

class User::PointRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_point_records_show_url
    assert_response :success
  end
end
