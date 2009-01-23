require 'test/test_helper'

class TorrentTest < ActiveSupport::TestCase
  test "negative size torrent" do
    t = Torrent.new(:name => "Blah", :meta_info => "some data")
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

    good.meta_info = nil
    assert !good.valid?
    good.meta_info = "blah"

    assert good.valid?
  end
end
