require "test_helper"

class User::CardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_cards_index_url
    assert_response :success
  end

  test "should get new" do
    get user_cards_new_url
    assert_response :success
  end

  test "should get edit" do
    get user_cards_edit_url
    assert_response :success
  end
end
