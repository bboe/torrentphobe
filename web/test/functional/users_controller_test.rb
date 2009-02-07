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

  test "should show user" do
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => users(:Jonathan).id}
    assert_response :success
  end

  test "should get edit" do
    @request.session[:user_id] = users(:Jonathan).id
    get :edit, :id => users(:Jonathan).id
    assert_response :success
  end

  test "should not get edit not owner" do
    @request.session[:user_id] = -1
    get :edit, :id => users(:Jonathan).id
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should update user" do
    @request.session[:user_id] = users(:Jonathan).id
    put :update, :id => users(:Jonathan).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user not owner" do
    @request.session[:user_id] = -1
    put :update, :id => users(:Jonathan).id, :user => { }
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should destroy user" do
    @request.session[:user_id] = users(:Jonathan).id
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:Jonathan).id
    end

    assert_redirected_to users_path
  end

    test "should not destroy user not owner" do
    @request.session[:user_id] = -1
    assert_difference('User.count', 0) do
      delete :destroy, :id => users(:Jonathan).id
    end
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should get specific user's files" do
    get :files, {:id => users(:Jonathan).id}, {:user_id => 2}
    assert_response :success
  end

  test "new user no friends login" do

    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :name => "testing", :uid => 12345))
    
    assert_difference('User.count', 1) do
      get :login
    end
    assert_redirected_to user_path(assigns(:user))
    assert_equal users(:LastUser).id+1, session[:user_id]
  end

  test "new user new friends login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [flexmock(:uid => jon.fb_id)], :name => "testing", :uid => 12345))
    assert_difference('User.count', 1) do
      assert_difference('Relationship.count', 2) do
        get :login
      end
    end
    assert_redirected_to user_path(assigns(:user))
    assert_equal users(:LastUser).id+1, session[:user_id]
  end

  test "old user no facebook login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :name => "testing", :uid => jon.fb_id))
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
