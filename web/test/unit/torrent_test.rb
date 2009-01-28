require 'test/test_helper'

class TorrentTest < ActiveSupport::TestCase
  test "negative size torrent" do
    t = Torrent.new(:name => "Blah", :data => "some data")
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

    assert good.valid?
  end

  test "create from torrent file" do
    t = Torrent.create_from_file(File.expand_path(File.dirname(__FILE__) + "/test.torrent"))
    assert t.valid?
    
    assert_equal "ubuntu-8.04.2-desktop-amd64.iso", t.name
    assert_equal 730105856, t.size
    
  end
end
