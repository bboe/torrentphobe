require 'test/test_helper'
require 'flexmock/test_unit'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    #assert_difference('User.count') do
    #  post :create, :user => {:name => "Jon", :fb_id => 100, :friend_hash => "d41d8cd98f00b204e9800998ecf8427e"}
    #end

    #assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => users(:Jonathan).id}
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => users(:Jonathan).id
    assert_response :success
  end

  test "should update user" do
    put :update, :id => users(:Jonathan).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:Jonathan).id
    end

    assert_redirected_to users_path
  end

  test "should get specific user's files" do
    get :files, {:id => users(:Jonathan).id}, {:user_id => 2}
    assert_response :success
  end

  test "new user no friends login" do

    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :first_name => "testing", :last_name => "Ma Gee", :uid => 12345))
    
    assert_difference('User.count', 1) do
      get :login
    end
    assert_redirected_to user_path(assigns(:user))
    assert_equal 5, session[:user_id]
  end

  test "new user new friends login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [flexmock(:uid => jon.fb_id)], :first_name => "testing", :last_name => "Ma Gee", :uid => 12345))    
    assert_difference('User.count', 1) do
      assert_difference('Relationship.count', 2) do
        get :login
      end
    end
    assert_redirected_to user_path(assigns(:user))
    assert_equal 5, session[:user_id]
  end

  test "old user no facebook login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :first_name => "testing", :last_name => "Ma Gee", :uid => jon.fb_id))
    get :login
    assert_redirected_to user_path(assigns(:user))
    assert_equal 1, session[:user_id]
  end
  
#  test "old user removed friends login" do
#    bob = users(:Bob)
#    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :first_name => "Bob", :last_name => "", :uid => bob.fb_id))
#    assert_difference('Relationship.count', -2) do
#      get :login
#    end
#    assert_equal 1, session[:user_id]
#  end

end
