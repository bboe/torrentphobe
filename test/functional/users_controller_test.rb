require 'test/test_helper'
require 'flexmock/test_unit'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    @request.session[:user_id] = users(:Alice).id
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    #ensure the users list contains the users friends
    assert assigns(:users).find( users(:Bob) )
  end

  test "should get index - without enemies" do
    @request.session[:user_id] = users(:Alice).id
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    #ensure the users list contains the users friends
    assert_nil assigns(:users).find_by_id( users(:Jerry).id )
  end

  test "should not get index" do
    @request.session[:user_id] = -1
    get :index
    assert_redirected_to "/"

    @request.session[:user_id] = nil
    get :index
    assert_redirected_to "/"
  end

  test "should get new" do
    @request.session[:user_id] = users(:Jonathan).id
    get :new
    assert_response :success
  end

  test "should show user - user is self" do
    @request.session[:user_id] = users(:Bob).id
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => users(:Bob).id}
    assert_response :success
  end

  test "should show user - user is friend" do
    @request.session[:user_id] = users(:Bob).id
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => users(:Alice).id}
    assert_response :success
  end

  test "should not show user - invalid id" do
    @request.session[:user_id] = users(:Bob).id
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => "-1" }
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should not show user - not self or friend" do
    @request.session[:user_id] = users(:Bob).id
    @controller.facebook_session = flexmock(:user => flexmock(:friends => []))
    get :show, {:id => users(:Jonathan).id }
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should get edit" do
    @request.session[:user_id] = users(:Jonathan).id
    get :edit, :id => users(:Jonathan).id
    assert_response :success
  end

  test "should not get edit not owner" do
    @request.session[:user_id] = users(:Bob).id
    get :edit, :id => users(:Jonathan).id
    assert_redirected_to :controller => :users, :action => :index
  end

  test "should update user" do
    @request.session[:user_id] = users(:Jonathan).id
    put :update, :id => users(:Jonathan).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user - not owner" do
    @request.session[:user_id] = users(:Bob).id
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

    test "should not destroy user - not owner" do
    @request.session[:user_id] = users(:Bob).id
    assert_difference('User.count', 0) do
      delete :destroy, :id => users(:Jonathan).id
    end
    assert_redirected_to :controller => :users, :action => :index
  end
  
  ### Deprecated ###
  #test "should get specific user's files" do
  #  get :files, {:id => users(:Jonathan).id}, {:user_id => 2}
  #  assert_response :success
  #end

  test "should view own files" do
    @request.session[:user_id] = users(:Jerry).id

    get :files, { :id => users(:Jerry).id }
    assert_response :success
  end

  test "should view friends files" do
    @request.session[:user_id] = users(:Alice).id

    get :files, { :id => users(:Bob).id }
    assert_response :success
  end

  test "should not view non-friends files" do
    @request.session[:user_id] = users(:Bob).id

    get :files, { :id => users(:Tom).id }
    assert_redirected_to :controller => users, :action => :index
  end

  test "new user no friends login" do
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :name => "testing", :uid => 12345))
    
    assert_difference('User.count', 1) do
      get :login
    end
    assert_redirected_to :controller => :home, :action => :index
    assert ((users(:LastUser).id+2 == session[:user_id].to_i) or (users(:LastUser).id+1 == session[:user_id]))
  end

  test "new user new friends login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [flexmock(:uid => jon.fb_id)], :name => "testing", :uid => 12345))
    assert_difference('User.count', 1) do
      assert_difference('Relationship.count', 2) do
        get :login
      end
    end
    assert_redirected_to :controller => :home, :action => :index
    assert_equal users(:LastUser).id+1, session[:user_id]
  end

  test "old user no facebook login" do
    jon = users(:Jonathan)
    @controller.facebook_session = flexmock(:user => flexmock(:friends => [], :name => "testing", :uid => jon.fb_id))
    get :login
    assert_redirected_to :controller => :home, :action => :index
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
