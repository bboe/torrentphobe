class Torrent < ActiveRecord::Base
  require 'ezcrypto'
  require 'bencode'
  require 'digest/sha1'
  acts_as_taggable
  acts_as_ferret :fields => [:name, :tags_with_spaces], :remote => true
  acts_as_paranoid

  has_many :swarms
  has_many :users, :through => :swarms

  belongs_to :owner, :foreign_key => "owner_id", :class_name => "User"
  belongs_to :category

  validates_presence_of :name, :data, :category, :owner
  validates_numericality_of :size, :greater_than => 0

  KEY = EzCrypto::Key.decode('3gP03Z7GQ/sLeH3+MO0CPw==')

  def filename
    self.name + ".torrent"
  end

  def generate_torrent_file user, host_url
    btorrent = BEncode.load(self.data)
    btorrent["announce"] = tracker_url( user.id , host_url)
    btorrent["comment"] = "torrentphobe torrent for " + user.name
    btorrent.bencode
  end

  def torrent_file=(input)
    self.data = input.read
  end

  def encode_data
    info = BEncode.load(self.data)["info"]
    info["private"] = 1
    self.name = info["name"]
    self.size = calculate_size(info)
    self.data = {"info" => info}.bencode
    self.info_hash = Digest::SHA1.digest(info.bencode)
  end

  private
  def tracker_url( user_id = nil, host_url="" )
    encrypted = KEY.encrypt64( user_id.to_s + "/" + self.id.to_s )
    host_url + "/swarms/a/" + encrypted[0...-3]
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

  def tags_with_spaces
    return self.tag_names.join(" ")
  end
end
