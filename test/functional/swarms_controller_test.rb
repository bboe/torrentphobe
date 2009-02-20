require 'test/test_helper'

class SwarmsControllerTest < ActionController::TestCase
  test "announce no params fail" do
    get :a
    assert_response :error
  end

  test "announce right params" do
    good = swarms(:good)
    get(:a, {:id => ["YrzCSV+QpwfcSs", "AYxRK3g"],
          :peer_id => good.peer_id, :port => good.port, :ip => good.ip_address,
          :info_hash => "JEFF_IS_THE_SHIZNIT1"})
    assert_response 500
  end



  test "announce results test" do
    good = swarms(:good)
    get(:a, {:id => ["YrzCSV+QpwfcSs", "AYxRK3g"],
          :peer_id => good.peer_id, :port => good.port, :ip => good.ip_address,
          :info_hash => "JEFF_IS_THE_SHIZNIT6"})
    
    result = BEncode.load(@response.body)
    assert_equal good.peer_id, result["peers"][0]["peer id"]
    assert_equal good.ip_address, result["peers"][0]["ip"]
    assert_equal good.port, result["peers"][0]["port"]
    assert_equal 0, result["complete"]
    assert_equal 1, result["incomplete"]
  end

  test "announce bad encrypted64" do
    get(:a, {:id => ["jeffrockers!"], :peer_id => "TESTID", :port => "6882",
          :info_hash => "JEFF_IS_THE_SHIZNIT3", :ip => "127.0.0.1"})
    result = BEncode.load(@response.body)
    assert_equal "Invalid announce URL.", result["failure"]
  end

  test "announce new completed to swarm" do
    assert_difference("Swarm.count", 1) do
      get(:a, {:id => ["YrzCSV+QpwfcSs", "AYxRK3g"],
            :peer_id => "NEW_PEER", :port => 8080, :event => "completed", 
            :info_hash => "JEFF_IS_THE_SHIZNIT6", :ip => "127.0.0.1"})
      result = BEncode.load(@response.body)
    end
    assert_response :success
    result = BEncode.load(@response.body)
    assert_equal 1, result["complete"]
    assert_equal 0, result["incomplete"]
  end

  test "announce new seeder started to swarm" do
    assert_difference("Swarm.count", 1) do
      get(:a, {:id => ["YrzCSV+QpwfcSs", "AYxRK3g"],
            :peer_id => "NEW_PEER", :port => 8080, :event => "started",
            :left => "0", :info_hash => "JEFF_IS_THE_SHIZNIT6",
            :ip => "127.0.0.1"})
    end
    assert_response :success
    result = BEncode.load(@response.body)
    assert_equal 1, result["complete"]
    assert_equal 0, result["incomplete"]
  end

  test "announce new started to swarm" do
    assert_difference("Swarm.count", 1) do

      get(:a, {:id => ["YrzCSV+QpwfcSs", "AYxRK3g"],
            :peer_id => "NEW_PEER", :port => 8080, :event => "started",
            :info_hash => "JEFF_IS_THE_SHIZNIT6", :ip => "127.0.0.1"})
    end
    assert_response :success
    result = BEncode.load(@response.body)
    assert_equal 0, result["complete"]
    assert_equal 1, result["incomplete"]
  end

    
end
