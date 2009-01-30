class Torrent < ActiveRecord::Base
  require 'bencode'
  validates_presence_of :name, :size, :data
  validates_numericality_of :size, :greater_than => 0

  SECRECT_KEY = 'jeffsucksandrules78978952yuihlkf'

  def filename
    self.name + ".torrent"
  end

  def generate_torrent_file user_id
    btorrent = BEncode.load(self.data)
    btorrent["announce"] = self.tracker_url( user_id )
    btorrent.bencode
  end

  def tracker_url user_id = nil
    host = "http://localhost:3000/"
    hash = Digest::SHA1.hexdigest( self.id.to_s + SECRECT_KEY + user_id.to_s )
    host + "swarms/announce/" + CGI.escape(hash) + "/" + self.id.to_s + "/" + user_id.to_s
  end
  
  def self.updatetorrentfile(upload)
     @tempname = upload['torrentfile'].original_filename
     @tempsize = upload['torrentfile'].size
     @tempmeta_info = upload['torrentfile'].read    
  end

  def self.create_from_file(path)
    info = BEncode.load_file(path)
    info["comment"] = ""
    info["info"]["private"] = 1
    Torrent.create( {:name => info["info"]["name"], :size => info["info"]["piece length"], :data => info.bencode} )
  end

end
