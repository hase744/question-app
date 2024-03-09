require "test_helper"

class Sample::RequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sample_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get sample_requests_show_url
    assert_response :success
  end
end
