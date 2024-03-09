require "test_helper"

class User::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get user_accounts_edit_url
    assert_response :success
  end

  test "should get show" do
    get user_accounts_show_url
    assert_response :success
  end
end
