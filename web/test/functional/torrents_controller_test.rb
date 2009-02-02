require 'test/test_helper'

class TorrentsControllerTest < ActionController::TestCase


  test "should get index" do
    get :index
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
    get :edit, :id => torrents(:one).id
    assert_response :success
  end

  test "should update torrent" do
    put :update, {:id => torrents(:one).id, :torrent => { } }
    assert_redirected_to torrent_path(assigns(:torrent))
  end

  test "should destroy torrent" do
    assert_difference('Torrent.count', -1) do
      delete :destroy, :id => torrents(:one).id
    end

    assert_redirected_to torrents_path
  end

  test "should download torrent" do
    good = torrents(:good)
    jon = users("Jonathan")
    get :download_torrent_file, {:id => good.id}, {:user_id => jon.id}
    result = BEncode.load(@response.body)
    assert_equal "http://localhost:3000/swarms/announce/7e5e55f19fd4a98378949678842a24aebb799231/3/1", result["announce"]
  end
end
