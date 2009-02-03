class Torrent < ActiveRecord::Base
  require 'digest/sha1'
  require 'bencode'
  acts_as_taggable

  has_many :swarms
  has_many :users, :through => :swarms

  belongs_to :owner, :foreign_key => "owner_id", :class_name => "User"
  belongs_to :category
  validates_presence_of :name, :data, :category, :owner
  validates_numericality_of :size, :greater_than => 0

  SECRECT_KEY = 'jeffsucksandrules78978952yuihlkf'
  HOST = "http://ec2-174-129-147-140.compute-1.amazonaws.com"

  def filename
    self.name + ".torrent"
  end

  def generate_torrent_file user_id
    btorrent = BEncode.load(self.data)
    btorrent["announce"] = tracker_url( user_id )
    btorrent.bencode
  end

  def torrent_file=(input)
    self.data = input.read
  end

  def encode_data
    info = BEncode.load(self.data)
    info["comment"] = ""
    info["info"]["private"] = 1
    self.name = info["info"]["name"]
    self.size = calculate_size( info["info"] )
    self.data = info.bencode
  end

  private
  def tracker_url user_id = nil
    hash = Digest::SHA1.hexdigest( self.id.to_s + SECRECT_KEY + user_id.to_s )
    HOST + "swarms/announce/" + CGI.escape(hash) + "/" + self.id.to_s + "/" + user_id.to_s
  end

  def calculate_size info
    if info["files"]
      total = 0
      for file in info["files"]
        total += file["length"]
      end
      total
    else
      info["length"]
    end
  end
end
