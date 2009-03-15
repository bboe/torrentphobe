# 1 torrent per user
# 20 friends per user
# 5000 unique tags
# 3 tags per torrent
class Array
  def shuffle
    sort_by { rand }
  end

  def shuffle!
    replace shuffle
  end
end


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
task( :generate_data => :environment) do
  User.delete_all!
  Relationship.delete_all!
  Torrent.delete_all!
  Swarm.delete_all

  #Grab the cateogries
  category_ids = Category.find(:all).map{ |c| c.id }
  
  #Grab a bunch of tags from a dictionary
  tag_list = []
  begin
    file=File.new('/usr/share/dict/words','r')
  rescue => err
    puts "Unable to open dictionary file! Exiting script."
    return
  end
  

  5000.times do |i|
    word = file.gets.strip
    #The database barfs when sees weird characters, so avoid them like the plauge
    redo if (word.include?("'") || (word.toutf8 != word))
    tag_list << word
  end
  file.close

  USERS = 10000
  # Add bunch of users
  last_id = nil
  USERS.times do |u_num|
    u = User.create(:name => "User_#{(u_num+1).to_s}", :fb_id => u_num+1, :friend_hash => 'bob')

    #Create a torrent which this user owns
    t = Torrent.create(:name => u.id.to_s, :size => "1", :meta_info => "1", 
                       :category_id => category_ids.shuffle[0], :owner_id=> u.id, 
                       :data => "7",
                       :info_hash => rand(10000) )
    #Save the info hash again to avoid having to deal with hashes when generating urls
    t.info_hash = u.id.to_s
    t.save

    tags = []
    #Pick three tags at random
    3.times do |i|
      tags << tag_list[rand(tag_list.length)]
    end

    #Add those tags to the torrent
    t.tag_list.add(tags)
    if !t.save
      print "Error saving torrent"
    end
    if rand(5) == 2 
      #Dont insert a swarm entry for each user, just some fraction of them
      Swarm.add_or_update_swarm(t.id, u.id,rand(1000), "192.168.0.1", "9090","started")
    end
    puts u_num.to_s + "\n"
    last_id = u.id
  end
  start_id = last_id - USERS + 1

  #Add relationships for users
  USERS.times do |i|
    user_id = start_id + i
    friends = []

    #Group all of a users friend inserts into a single transaction for faster inserts
    ActiveRecord::Base.transaction do  
      8.times do |j|
        friend_id = start_id+rand(USERS)

        #dont add the relationship if they are the same user, or al already friends
        redo if(friend_id == user_id || friends.include?(friend_id))

        #Catch any failed inserts when duplicates exist, much faster than looking for each pair before inserting
        begin
          insert_1 = "INSERT INTO relationships (user_id,friend_id) VALUES (#{user_id},#{friend_id})"
          ActiveRecord::Base.connection.execute(insert_1)
        rescue
          redo
        end

        insert_2 = "INSERT INTO relationships (user_id,friend_id) VALUES (#{friend_id},#{user_id})"
        ActiveRecord::Base.connection.execute(insert_2)
        friends << friend_id
      end
    end
    puts i
  end
end

desc "Gets a set of valid announce urls"
task( :generate_announce_urls => :environment) do
  require 'ezcrypto'
  #This is only temporarily here to allow urls to be created. Remove when not needed.
  KEY = EzCrypto::Key.decode('3gP03Z7GQ/sLeH3+MO0CPw==')
  
  torrents = Torrent.find(:all)
  users = User.find(:all)
  #Generate 50 valid announce urls
  10000.times do |i|
    #pick random a random torrent and random user
    u = users[rand(users.length)]
    t = torrents[rand(torrents.length)]
    encrypted = KEY.encrypt64( u.id.to_s + "/" + t.id.to_s )
    peer_id = rand(100000)
    port = 6060
    id = encrypted[0...-3]

    #info_hash is the owner_id as set in generate_data rake task
    info_hash=t.owner_id
    url = "/swarms/a/" + encrypted[0...-3] + "?peer_id=#{peer_id}&port=#{port}&info_hash=#{info_hash}"
    puts url
  end
end

