class Torrent < ActiveRecord::Base
  require 'ezcrypto'
  require 'bencode'
  require 'config/global_config.rb'
  acts_as_taggable
  acts_as_ferret :fields => [:name, :tags_with_spaces], :remote => true

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

  def generate_torrent_file user_id, host_url
    btorrent = BEncode.load(self.data)
    btorrent["announce"] = tracker_url( user_id , host_url)
    btorrent.bencode
  end

  # This gets the list of torrents depending on friend relationships.  Returns owned torrents, user's active torrents, and user's friends' active torrents
  def self.get_torrents_for_user( uid ) 
    torrents = []
    begin 
       user = User.find_by_id(uid)
       if user == nil
	  torrents
       end

       if user.friends
	  torrents = user.friends.map {|friend| friend.torrents }
       end
       torrents << user.torrents
       torrents << user.owned_torrents
       torrents = torrents.flatten.uniq

       torrents

    rescue
      torrents

    end
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
  def tracker_url( user_id = nil, host_url="" )
    encrypted = KEY.encrypt64( self.id.to_s + "/" + user_id.to_s )
    host_url + "/swarms/announce/" + encrypted[0...-3]
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
