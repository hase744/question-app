require "test_helper"

class User::ConnectsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_connects_index_url
    assert_response :success
  end

  test "should get new" do
    get user_connects_new_url
    assert_response :success
  end

  test "should get edit" do
    get user_connects_edit_url
    assert_response :success
  end
end
