class User < ActiveRecord::Base
  has_many :relationships
  has_many :friends, :through => :relationships, :uniq => true

  has_many :swarms
  has_many :torrents, :through => :swarms

  has_many :owned_torrents, :foreign_key => :owner_id, :class_name => "Torrent" 

  validates_presence_of :name, :friend_hash, :fb_id
  validates_numericality_of :fb_id, :greater_than => 0

  def add_friend(friend)
    Relationship.find_or_create_by_user_id_and_friend_id(self.id, friend.id)
    Relationship.find_or_create_by_user_id_and_friend_id(friend.id, self.id)
  end

  def update_info(friend_ids, name)
    # Does not save
    self.name = name
    self.friend_hash = Digest::MD5.hexdigest( friend_ids.to_s )
    user_ids = User.find( :all, :select => :fb_id ).map! { |user| user.fb_id }
    friends = user_ids & friend_ids
    friends.each do |friend|
      friend = User.find_by_fb_id(friend)
      self.add_friend(friend)
    end
  end
end
