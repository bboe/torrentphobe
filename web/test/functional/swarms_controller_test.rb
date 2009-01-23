require 'test/test_helper'

class SwarmsControllerTest < ActionController::TestCase
  test "announce no params fail" do
    get :announce
    assert_response :error
  end

  test "announce right params" do
    get :announce, {:peer_id => "TESTID", :port => "6882"}
    assert_response :success      
  end
  
end
