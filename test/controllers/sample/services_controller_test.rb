require "test_helper"

class Sample::ServicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sample_services_index_url
    assert_response :success
  end

  test "should get show" do
    get sample_services_show_url
    assert_response :success
  end
end
