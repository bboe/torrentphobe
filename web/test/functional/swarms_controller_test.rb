require 'test_helper'

class SwarmsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:swarms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create swarm" do
    assert_difference('Swarm.count') do
      post :create, :swarm => { }
    end

    assert_redirected_to swarm_path(assigns(:swarm))
  end

  test "should show swarm" do
    get :show, :id => swarms(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => swarms(:one).id
    assert_response :success
  end

  test "should update swarm" do
    put :update, :id => swarms(:one).id, :swarm => { }
    assert_redirected_to swarm_path(assigns(:swarm))
  end

  test "should destroy swarm" do
    assert_difference('Swarm.count', -1) do
      delete :destroy, :id => swarms(:one).id
    end

    assert_redirected_to swarms_path
  end
end
