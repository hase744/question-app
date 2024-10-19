require "test_helper"

class User::BalanceRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_balance_records_show_url
    assert_response :success
  end
end
