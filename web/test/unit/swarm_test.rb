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
end
