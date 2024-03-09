require "test_helper"

class User::ServicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_services_index_url
    assert_response :success
  end

  test "should get show" do
    get user_services_show_url
    assert_response :success
  end

  test "should get new" do
    get user_services_new_url
    assert_response :success
  end

  test "should get edit" do
    get user_services_edit_url
    assert_response :success
  end

  test "should get create" do
    get user_services_create_url
    assert_response :success
  end

  test "should get destroy" do
    get user_services_destroy_url
    assert_response :success
  end
end
