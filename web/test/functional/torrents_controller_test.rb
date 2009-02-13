require 'test/test_helper'
require 'flexmock/test_unit'
require 'config/global_config.rb'

class TorrentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, {:user_id => users(:Tom).id}
    assert_response :success
    assert_not_nil assigns(:torrents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create torrent" do
    assert_difference('Torrent.count') do
      file = ActionController::TestUploadedFile.new(File.expand_path(File.dirname(__FILE__) + "/../test.torrent"), "application/x-bittorrent")

      post :create, { :torrent => {:name => "test", :size => 4050, :meta_info => "some info", :data => "test data", :category_id => 1, :torrent_file => file  }},  {:user_id => 1}
    end

    assert_redirected_to torrent_path(assigns(:torrent))
  end

  test "should show torrent" do
    get :show, :id => torrents(:one).id
    assert_response :success
  end

  test "should get edit" do
    @request.session[:user_id] = torrents(:one).owner_id
    get :edit, :id => torrents(:one).id
    assert_response :success
  end

  test "should not get edit torrent not owner" do
    @request.session[:user_id] = -1
    get :edit, :id => torrents(:one).id
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should update torrent" do
    @request.session[:user_id] = torrents(:one).owner_id
    put :update, {:id => torrents(:one).id, :torrent => { } }
    assert_redirected_to torrent_path(assigns(:torrent))
  end

  test "should not update torrent not owner" do
    @request.session[:user_id] = -1
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
    @request.session[:user_id] = -1
    assert_difference('Torrent.count', 0) do
      delete :destroy, :id => torrents(:one).id
    end
    assert_redirected_to :controller => :torrents, :action => :index
  end

  test "should download torrent" do
    @request.env["HTTP_HOST"] = "http://torrentpho.be"
    good = torrents(:good)
    jon = users("Jonathan")
    get :download_torrent_file, {:id => good.id}, {:user_id => jon.id}
    result = BEncode.load(@response.body)
    assert_equal @request.env["HTTP_HOST"] +"/swarms/announce/7e5e55f19fd4a98378949678842a24aebb799231/3/1", result["announce"]
  end

end
