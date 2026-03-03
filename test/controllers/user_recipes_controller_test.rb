require "test_helper"

class UserRecipesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get user_recipes_create_url
    assert_response :success
  end
end
