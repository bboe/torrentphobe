require 'test/test_helper'

class TagsControllerTest < ActionController::TestCase
  test "index" do
    get :index, {}, {:user_id => users(:Tom)}
    assert_response :success
  end

  test "show" do
    get :show, {:id => 1}, {:user_id => users(:Tom)}
    assert_response :success
    assert assigns(:torrents).include?( torrents(:toms) )
  end


end
