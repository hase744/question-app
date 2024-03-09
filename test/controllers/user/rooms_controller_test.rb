require "test_helper"

class User::RoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_rooms_index_url
    assert_response :success
  end

  test "should get show" do
    get user_rooms_show_url
    assert_response :success
  end

  test "should get create" do
    get user_rooms_create_url
    assert_response :success
  end
end
