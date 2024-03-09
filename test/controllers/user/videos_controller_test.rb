require "test_helper"

class User::VideosControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_videos_show_url
    assert_response :success
  end
end
