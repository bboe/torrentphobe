# 1 torrent per user
# 20 friends per user
# 10 torrents per user
# 5000 unique tags
# 3 tags per torrent

desc "Purges the old entries in the swarm table"
task( :purge_swarms => :environment) do
  Swarm.delete_all(["updated_at < ?", 1.weeks.ago])
  stale = Swarm.find(:all, :conditions => ["updated_at < ? and status != 2",
                                           5.minutes.ago])
  stale.each do | item |
    item.status = 2
    item.save()
  end
end

desc "Adds shit ton of test data for performance evaluation!"
task( :shit_tonnes => :environment) do
  User.delete_all!
  Relationship.delete_all!
  Torrent.delete_all!

  USERS = 10
  # Add bunch of users
  last_id = nil
  USERS.times do |u_num|
    u = User.create(:name => "User_#{(u_num+1).to_s}", :fb_id => u_num+1,
                :friend_hash => 'bob')
    t = Torrent.create(:
    last_id = u.id
  end
  start_id = last_id - USERS + 1

  User.find(:all).each do |u|
    # ADD 20 FRIENDS
    20.times do |n|
      friend_id = start_id + rand(USERS)
      redo if friend_id == u.id
      Relationship.create(:user_id => u.id, :friend_id => friend_id)
      Relationship.create(:user_id => friend_id, :friend_id => u.id)
    end
    
    # ADD 1 to 1 torrents

  end
      

end

