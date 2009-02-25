require 'test/test_helper'

class HomeControllerTest < ActionController::TestCase
  test "home" do
    get :index, {}, {:user_id => users(:Tom)}
    assert_response :success
  end
end
