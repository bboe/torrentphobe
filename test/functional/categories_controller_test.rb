require 'test/test_helper'
require 'flexmock/test_unit'
class CategoriesControllerTest < ActionController::TestCase
  test "should get index" do
    @request.session[:user_id] = users(:Tom).id
    get :index
    assert_response :success
    assert_not_nil assigns(:torrents_by_category )
  end

  test "should not get index - invalid id" do
    @request.session[:user_id] = -1
    get :index
    assert_redirected_to "/"

    @request.session[:user_id] = nil
    get :index
    assert_redirected_to "/"
  end

  test "should get index with own torrents" do
    @request.session[:user_id] = users(:Tom).id
    get :index
    assert_response :success
    assert_not_nil assigns(:torrents_by_category).find(torrents(:toms))
  end

  test "should get index with friends torrents" do
    @request.session[:user_id] = users(:Alice).id
    #friends torrents need to be in the swam to be visible to friends
    Swarm.add_to_swarm(torrents(:bobs).id, users(:Bob).id, "peerid", "192.168.0.1", "3000")
    get :index
    assert_response :success
    assert_not_nil assigns(:torrents_by_category ).find(torrents(:bobs))
  end

  test "should show category" do
    @request.session[:user_id] = users(:Tom).id
    get :show, :id => torrents(:toms).category_id
    assert_response :success
  end

  test "should show category - including friends torrent" do
    @request.session[:user_id] = users(:Alice).id
    #friends torrents need to be in the swam to be visible to friends
    Swarm.add_to_swarm(torrents(:bobs).id, users(:Bob).id, "peerid", "192.168.0.1", "3000")

    get :show, :id => torrents(:bobs).category_id
    assert_response :success
    assert assigns(:torrents).include?(torrents(:bobs))
  end

  test "should show category - not enemies torrent" do
    @request.session[:user_id] = users(:Tom).id

    get :show, :id => torrents(:jerrys).category_id
    assert_response :success
    assert !assigns(:torrents).include?(torrents(:jerrys))
  end
end
  

