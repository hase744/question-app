require "test_helper"

class User::RequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get user_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get user_requests_new_url
    assert_response :success
  end

  test "should get edit" do
    get user_requests_edit_url
    assert_response :success
  end

  test "should get create" do
    get user_requests_create_url
    assert_response :success
  end

  test "should get destroy" do
    get user_requests_destroy_url
    assert_response :success
  end
end
