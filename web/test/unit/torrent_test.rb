require 'test/test_helper'

class TorrentTest < ActiveSupport::TestCase
  SERVER_ROOT = "http://localhost:3000/"
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
    assert_equal 524288, t.size
    


  end

  test "test filename method" do
    good = torrents(:good)
    assert_equal good.filename, "A Name.torrent"
  end

  test "generate torrent file" do
    good = torrents(:good)
    file = good.generate_torrent_file 1    
    assert_equal BEncode.load(file)["announce"], SERVER_ROOT + "swarms/announce/7e5e55f19fd4a98378949678842a24aebb799231/3/1"
  end

end
