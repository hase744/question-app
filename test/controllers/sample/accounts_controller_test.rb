require "test_helper"

class Sample::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sample_accounts_index_url
    assert_response :success
  end

  test "should get show" do
    get sample_accounts_show_url
    assert_response :success
  end
end
