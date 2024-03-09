require "test_helper"

class User::TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_transactions_index_url
    assert_response :success
  end

  test "should get edit" do
    get user_transactions_edit_url
    assert_response :success
  end

  test "should get show" do
    get user_transactions_show_url
    assert_response :success
  end
end
