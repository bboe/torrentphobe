class Torrent < ActiveRecord::Base
  require 'bencode'
  validates_presence_of :name, :size, :data
  validates_numericality_of :size, :greater_than => 0
  def self.updatetorrentfile(upload)
     @tempname = upload['torrentfile'].original_filename
     @tempsize = upload['torrentfile'].size
     @tempmeta_info = 10
     @tempdata = upload['torrentfile'].read    
  end

  def self.create_from_file(path)
    info = BEncode.load_file(path)
    info["comment"] = ""
    info["info"]["private"] = 1
    Torrent.create( {:name => info["info"]["name"], :size => info["info"]["piece length"], :data => info.bencode} )
  end

end
