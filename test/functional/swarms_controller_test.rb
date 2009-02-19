require 'test/test_helper'

class SwarmsControllerTest < ActionController::TestCase
  test "announce no params fail" do
    get :a
    assert_response :error
  end

  test "announce right params" do
    get :a, {:id => ['yXZlLdfEp1K9KtZKefIONQ'],
                    :peer_id => "TESTID", :port => "6882"}
    assert_response :success
  end

  test "announce results test" do
    good = swarms(:good)
    get :a, {:id => ['yXZlLdfEp1K9KtZKefIONQ'],
                    :peer_id => good.peer_id, :port => good.port}

    result = BEncode.load(@response.body)
    assert_equal result["peers"][0]["id"], good.peer_id
    assert_equal result["peers"][0]["ip"], good.ip_address
    assert_equal result["peers"][0]["port"], good.port
  end

  test "announce bad encrypted64" do
    get :a, {:id => ["jeffrockers!"], :peer_id => "TESTID", :port => "6882"}
    result = BEncode.load(@response.body)
    assert_equal "Invalid announce URL.", result["failure"]
  end

  test "announce new to swarm" do
    assert_difference("Swarm.count", 1) do
      get :a, {:id => ['VaFS3pGFGfyOBi1Xp','wcgA'],
        :peer_id => "NEW_PEER", :port => 8080, :event => "started"}
    end
    assert_response :success
  end

    
end
