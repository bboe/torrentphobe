# 1 torrent per user
# 16 friends per user
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
  puts "Deleting old data from the database..."
  User.delete_all!
  Relationship.delete_all!
  Torrent.delete_all!
  Swarm.delete_all
  Tag.delete_all
  Tagging.delete_all

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

  USERS = 100000

  puts "Inserting users into database..."
  # Add bunch of users
  (USERS/100).times do |u_num|
    #Break up user inserts into 100 row insert transactions to speed them up
    100.times do |i|
      uid = u_num*100+i
      ActiveRecord::Base.transaction do  
        insert_1 = "INSERT INTO users (name,fb_id,friend_hash,created_at,updated_at) VALUES ('User_#{(uid+1).to_s}',#{uid}, 'bob', NOW(), NOW())"
        ActiveRecord::Base.connection.execute(insert_1)
      end
      puts "Inserted #{uid} users" if uid % 100 == 0
    end
  end

  first_user = User.find(:first).id
  last_user = User.find(:last).id

  puts "Inserting torrents into database..."
  USERS.times do |t_num|
    uid = first_user+t_num
    t = Torrent.create(:name => uid.to_s, :size => "1", :meta_info => "1", 
                       :category_id => category_ids.shuffle[0], :owner_id=> uid, 
                       :data => "7",
                       :info_hash => rand(10000) )
    #Set the info hash again to avoid having to deal with hashes when generating urls
    t.info_hash = uid.to_s

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

    if rand(5) < 3
      #Dont insert a swarm entry for each user, just some fraction of them
      Swarm.add_or_update_swarm(t.id, uid,rand(1000), "192.168.0.1", "9090","started")
    end
    puts "Inserted #{t_num} torrents" if t_num % 100 == 0
  end

  #Add relationships for users
  USERS.times do |i|
    user_id = first_user + i
    friends = []

    #Group all of a users friend inserts into a single transaction for faster inserts
    ActiveRecord::Base.transaction do  
      8.times do |j|
        friend_id = first_user+rand(USERS)

        #dont add the relationship if they are the same user, or al already friends
        redo if(friend_id == user_id || friends.include?(friend_id))

        #Catch any failed inserts when duplicates exist, much faster than looking for each pair before inserting
        begin
          insert_1 = "INSERT INTO relationships (user_id,friend_id, created_at, updated_at) VALUES (#{user_id},#{friend_id}, NOW(), NOW())"
          ActiveRecord::Base.connection.execute(insert_1)
        rescue
          redo
        end

        insert_2 = "INSERT INTO relationships (user_id,friend_id, created_at, updated_at) VALUES (#{friend_id},#{user_id}, NOW(),NOW())"
        ActiveRecord::Base.connection.execute(insert_2)
        friends << friend_id
      end
    end
    puts "Inserted #{i} relationships" if i % 1000 == 0
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

