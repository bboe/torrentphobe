class User < ActiveRecord::Base  
  has_many :relationships
  has_many :friends, :through => :relationships, :uniq => true

  has_many :swarms

  has_many :owned_torrents, :foreign_key => :owner_id, :class_name => "Torrent" 

  acts_as_paranoid

  validates_presence_of :name, :friend_hash, :fb_id
  validates_numericality_of :fb_id, :greater_than => 0

  def self.sanitize_fucking_sql *args
    sanitize_sql *args
  end

  # Can pass in any of the find options (such as order), as well as :page_id and :num_per_page for pagination
  def torrents args = {}
    limit = (args[:limit] ? "limit #{args[:limit]}" : "")
    offset = (args[:offset] ? "offset #{args[:offset]}" : "")
    order = (args[:order] ? "order by #{args[:order]}" : "")
    extra_conditions =  (User.sanitize_fucking_sql(args.delete(:conditions)) || "")
    extra_conditions = " AND " + extra_conditions if extra_conditions.length > 0
    Torrent.find_by_sql(["select * from (SELECT torrents.* FROM torrents, relationships, swarms WHERE (relationships.friend_id = swarms.user_id AND relationships.user_id = :user_id AND swarms.torrent_id = torrents.id)" + extra_conditions + " UNION SELECT torrents.* FROM torrents, swarms WHERE (swarms.torrent_id = torrents.id AND swarms.user_id = :user_id)" + extra_conditions + ") as torrents #{order} #{limit} #{offset}", {:user_id => self.id}])
  end

  def torrent_count args = {}
    extra_conditions =  (User.sanitize_fucking_sql(args.delete(:conditions)) || "")
    extra_conditions = " AND " + extra_conditions if extra_conditions.length > 0
    Torrent.count_by_sql(["select count(*) from (SELECT torrents.id FROM torrents, relationships, swarms WHERE (relationships.friend_id = swarms.user_id AND relationships.user_id = :user_id AND swarms.torrent_id = torrents.id) #{extra_conditions} UNION SELECT torrents.id FROM torrents, swarms WHERE (swarms.torrent_id = torrents.id AND swarms.user_id = :user_id) #{extra_conditions}) as torrents", {:user_id => self.id}])
  end

  def add_friend(friend)
    Relationship.find_or_create_by_user_id_and_friend_id(self.id, friend.id)
    Relationship.find_or_create_by_user_id_and_friend_id(friend.id, self.id)
  end

  def my_torrents
    torrents = []
    begin 
       torrents = self.owned_torrents.flatten.uniq
    rescue
      torrents
    end
  end

  def valid_friend?(uid)
    if self.friends.find_by_id( uid ) == nil
      return false
    else
      return true
    end
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
