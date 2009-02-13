require 'test/test_helper'
require 'flexmock/test_unit'

class Admin::UsersControllerTest < ActionController::TestCase
  test "should fail login no facebook session" do
    get :index
    assert_redirected_to "/"
  end

  test "should fail login not admin fb_id" do
    alice = users(:Alice)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [flexmock(:uid => alice.fb_id)], :name => "Alice", :uid => 1234567))
    get :index
    assert_redirected_to "/"
  end

  test "should successfully login" do
    adam = users(:Adam)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [flexmock(:uid => adam.fb_id)], :name => "Adam", :uid => adam.fb_id))
    get :index
    assert_response :success
  end
end
