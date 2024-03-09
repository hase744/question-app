require "test_helper"

class User::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_contacts_index_url
    assert_response :success
  end

  test "should get show" do
    get user_contacts_show_url
    assert_response :success
  end
end
