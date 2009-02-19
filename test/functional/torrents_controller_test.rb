require 'test/test_helper'
require 'flexmock/test_unit'
require 'config/global_config.rb'

class TorrentsControllerTest < ActionController::TestCase
  test "should get index" do
    @request.session[:user_id] = users(:Tom).id
    get :index
    assert_response :success
    assert_not_nil assigns(:torrents)
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
    assert assigns(:torrents).include?(torrents(:toms))
  end

  test "should get index with friends torrents" do
    @request.session[:user_id] = users(:Alice).id
    #friends torrents need to be in the swam to be visible to friends
    Swarm.add_or_update_swarm(torrents(:bobs).id, users(:Bob).id, "peerid", "192.168.0.1", "3000", "started")

    get :index
    assert_response :success
    assert assigns(:torrents).include?(torrents(:bobs))
  end

  test "should get index without enemies torrents" do
    @request.session[:user_id] = users(:Tom).id
    #Add enemies torrent to swarm to ensure it is visible to friends
    Swarm.add_or_update_swarm(torrents(:jerrys).id, users(:Jerry).id, "peerid", "192.168.0.1", "3000", "started")

    get :index
    assert_response :success
    assert !assigns(:torrents).include?( torrents(:jerrys) )
  end

  test "should get new" do
    @request.session[:user_id] = users(:Tom).id
    get :new
    assert_response :success
  end

  test "should create torrent" do
    @request.session[:user_id] = users(:Tom).id
    assert_difference('Torrent.count') do
      file = ActionController::TestUploadedFile.new(File.expand_path(File.dirname(__FILE__) + "/../test.torrent"), "application/x-bittorrent")

      post :create, { :torrent => {:name => "test", :size => 4050, :meta_info => "some info", :data => "test data", :category_id => 1, :torrent_file => file  }}
    end

    assert_redirected_to torrent_path(assigns(:torrent))
  end

  test "should show torrent" do
    @request.session[:user_id] = users(:Tom).id
    get :show, :id => torrents(:toms).id
    assert_response :success
  end

  test "should show torrent - friends torrent" do
    @request.session[:user_id] = users(:Alice).id

    get :show, :id => torrents(:bobs).id
    assert_response :success
  end

  test "should not show torrent - not owner or friend" do
    @request.session[:user_id] = users(:Tom).id

    get :show, :id => torrents(:jerrys).id
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should get edit" do
    @request.session[:user_id] = torrents(:one).owner_id
    get :edit, :id => torrents(:one).id
    assert_response :success
  end

  test "should not get edit torrent not owner" do
    @request.session[:user_id] = torrents(:one).owner_id+1
    get :edit, :id => torrents(:one).id
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should update torrent" do
    @request.session[:user_id] = torrents(:one).owner_id
    put :update, {:id => torrents(:one).id, :torrent => { } }
    assert_redirected_to torrent_path(assigns(:torrent))
  end

  test "should not update torrent not owner" do
    @request.session[:user_id] = torrents(:one).owner_id+1
    put :update, {:id => torrents(:one).id, :torrent => { } }
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should destroy torrent" do
    @request.session[:user_id] = torrents(:one).owner_id
    assert_difference('Torrent.count', -1) do
      delete :destroy, :id => torrents(:one).id
    end

    assert_redirected_to torrents_path
  end

  test "should not destroy torrent not owner" do
    @request.session[:user_id] = torrents(:one).owner_id+1
    assert_difference('Torrent.count', 0) do
      delete :destroy, :id => torrents(:one).id
    end
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should download torrent" do
    @request.session[:user_id] = users(:Jonathan).id
    @request.env["HTTP_HOST"] = "torrentpho.be"
    good = torrents(:good)
    jon = users("Jonathan")
    get :download_torrent_file, {:id => good.id}
    result = BEncode.load(@response.body)
    assert_equal "http://torrentpho.be/swarms/a/yXZlLdfEp1K9KtZKefIONQ", result["announce"]
  end


end
