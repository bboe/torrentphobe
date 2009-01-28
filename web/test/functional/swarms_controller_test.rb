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
  
  test "announce results test" do
    good = swarms(:good)
    get :announce, {:peer_id => good.peer_id, :port => good.port}
    result = BEncode.load(@response.body)
    assert_equal result["peers"][0]["id"], good.peer_id
    assert_equal result["peers"][0]["ip"], good.ip_address
    assert_equal result["peers"][0]["port"], good.port
  end
  
end
