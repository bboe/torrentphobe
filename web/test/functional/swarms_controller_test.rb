require 'test/test_helper'

class SwarmsControllerTest < ActionController::TestCase
  test "announce no params fail" do
    get :announce
    assert_response :error
  end

  test "announce right params" do
    get :announce, {:encrypted64 => 'yXZlLdfEp1K9KtZKefIONQ',
                    :peer_id => "TESTID", :port => "6882"}
    assert_response :success      
  end
  
  test "announce results test" do
    good = swarms(:good)
    get :announce, {:encrypted64 => 'yXZlLdfEp1K9KtZKefIONQ',
                    :peer_id => good.peer_id, :port => good.port}

    result = BEncode.load(@response.body)
    assert_equal result["peers"][0]["id"], good.peer_id
    assert_equal result["peers"][0]["ip"], good.ip_address
    assert_equal result["peers"][0]["port"], good.port
  end

  test "announce bad encrypted64" do
    get :announce, {:encrypted64 => "jeffrockers!", :peer_id => "TESTID", :port => "6882"}
    result = BEncode.load(@response.body)
    assert_equal "Invalid announce URL.", result["failure"]
  end

  
  
end
