require 'test/test_helper'

class SwarmTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "valid port" do
    good = swarms(:good)
    assert good.valid?

    good.port = -1000
    assert !good.valid?, "negative port!"

    good.port = 0
    assert !good.valid?, "zero port!"

    good.port = 65536
    assert !good.valid?, "too big a port!"

    good.port = 6881
    assert_valid(good)
  end

  test "missing options" do
    good = swarms(:good)
    assert_valid(good)

    bad = good.clone
    
    bad.user_id = nil
    assert !bad.valid?, "need a user id!"
    bad.user_id = good.user_id

    bad.torrent_id = nil
    assert !bad.valid?, "need torrent id!"
    bad.torrent_id = good.torrent_id

    bad.ip_address = nil
    assert !bad.valid?, "need ip address!"
    bad.ip_address = good.ip_address

    bad.port = nil
    assert !bad.valid?, "need port!"
    bad.port = good.port

    bad.peer_id = nil
    assert !bad.valid?, "need peer_id!"
    bad.peer_id = good.peer_id

    assert_valid bad    
  end

  test "invalid ip_address" do
    good = swarms(:good)

    good.ip_address = 18958953
    assert !good.valid?, "ip address is integer"

    good.ip_address = "256.10.2.0"
    assert !good.valid?, "One of the octals greater than 255"

    good.ip_address = "129.0.1"
    assert !good.valid?, "Not enough octals"

    good.ip_address = "aba.111.48.51"
    assert !good.valid?, "one of the octals is not a number"

    good.ip_address = "128.111.48.52"
    assert_valid(good)
    
  end

  test "get swarm list with friends" do
    #Bob is seeding his own torrent
    Swarm.add_to_swarm(torrents(:bobs).id, users(:Bob).id, "peerid", "192.168.0.1", "3000", "started")

    #Alice (his friend) gets the swarm list
    swarm_list = Swarm.get_swarm_list(torrents(:bobs).id, users(:Alice).id)

    users_in_swarm = swarm_list.map(&:user_id)

    #Alice should see Bob in the swarm
    assert users_in_swarm.include?(users(:Bob).id)
    
    #Alice (his friend) gets the swarm list
    swarm_list = Swarm.get_swarm_list(torrents(:bobs).id, users(:Bob).id)

    users_in_swarm = swarm_list.map(&:user_id)

    #Alice should see Bob in the swarm
    assert users_in_swarm.include?(users(:Bob).id)
  end

  test "get swarm list without enemies" do
    #Tom is seeding his own torrent
    Swarm.add_to_swarm(torrents(:toms).id, users(:Tom).id, "peerid", "192.168.0.1", "3000", "started")

    #Jerry (his enemy) gets the swarm list
    swarm_list = Swarm.get_swarm_list(torrents(:toms).id, users(:Jerry).id)

    users_in_swarm = swarm_list.map(&:user_id)

    #Jerry should not see Tom in the swarm
    assert !users_in_swarm.include?(users(:Tom).id)
  end

  test "get swarm list with friends and without enemies" do
    #Bob is seeding his own torrent
    Swarm.add_to_swarm(torrents(:bobs).id, users(:Bob).id, "peerid", "192.168.0.1", "3000", "started")
    Swarm.add_to_swarm(torrents(:bobs).id, users(:Tom).id, "peerid", "192.168.0.2", "3000", "started")

    #Alice (Bobs friend, Toms enemy) gets the swarm list
    swarm_list = Swarm.get_swarm_list(torrents(:bobs).id, users(:Alice).id)

    users_in_swarm = swarm_list.map(&:user_id)

    #Alice should see Bob in the swarm
    assert users_in_swarm.include?(users(:Bob).id)
    #Alice should not see Tom in the swarm
    assert !users_in_swarm.include?(users(:Tom).id)
  end

  test "update swarm" do
    good = swarms(:good)
    Swarm.update_swarm good.torrent_id, good.user_id, good.peer_id, good.ip_address, good.port, "stopped"
    assert_equal 2, Swarm.find(good.id).status
  end

  test "get seeders" do
    good = swarms(:good)
    assert_equal 0, Swarm.get_seeders(good.torrent_id)
    Swarm.update_swarm(good.torrent_id, good.user_id, good.peer_id, good.ip_address, good.port, "completed")
    assert_equal 1, Swarm.get_seeders(good.torrent_id)    
  end

  test "get leechers" do
    good = swarms(:good)
    assert_equal 1, Swarm.get_leechers(good.torrent_id)    
    Swarm.update_swarm(good.torrent_id, good.user_id, good.peer_id, good.ip_address, good.port, "completed")
    assert_equal 0, Swarm.get_leechers(good.torrent_id)    
  end

  test "get_swarm_list" do
    
  end


end
