require 'test/test_helper'
require 'config/global_config.rb'

class TorrentTest < ActiveSupport::TestCase
  test "negative size torrent" do
    t = torrents(:good)

    t.size = -100
    assert !t.valid?

    t.size = 0
    assert !t.valid?

    t.size = 100
    assert t.valid?
  end
  
  test "missing fields" do
    good = torrents(:good)

    assert good.valid?

    good.name = nil
    assert !good.valid?
    good.name = "Good"
    
    good.size = nil
    assert !good.valid?
    good.size = 1000

    good.data = nil
    assert !good.valid?
    good.data = "blah"

    good.owner = nil
    assert !good.valid?
    good.owner = users(:Jonathan)

    assert good.valid?
  end

  test "create torrent" do
    t = Torrent.new
    t.data = File.new(File.expand_path(File.dirname(__FILE__) + "/../test.torrent")).readlines.to_s
    t.encode_data
    t.category_id = 1

    jon = users(:Jonathan)
    
    t.owner = jon
    assert t.valid?

    assert_equal jon.id, t.owner_id
    assert_equal "ubuntu-8.04.2-desktop-amd64.iso", t.name
    assert_equal 730105856, t.size
  end

  test "generate torrent file" do
    good = torrents(:good)
    user = users(:Jonathan)
    file = good.generate_torrent_file user, "http://torrentpho.be"
    torrent = BEncode.load(file)
    assert_equal("http://torrentpho.be/swarms/a/yXZlLdfEp1K9KtZKefIONQ",
                 torrent["announce"])
    assert_equal "torrentphobe torrent for " + user.name, torrent["comment"]
  end

  test "get users downloading/seeding a torrent" do
    good_torrent = torrents(:good)
    jon = users(:Jonathan)
    assert_equal [jon], good_torrent.users
  end

  test "delete torrents" do
    good = torrents(:good)
    assert_difference("Torrent.count", -1) do
      good.delete
      good.save
    end
    assert !Torrent.exists?(good.id)
    u = Torrent.find_by_sql("select * from torrents where id = " + good.id.to_s)[0]
    assert_equal good, u        
  end 

end
