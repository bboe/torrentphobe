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
    insert_1 = "INSERT INTO tags (name) VALUES ('#{word}')"
    ActiveRecord::Base.connection.execute(insert_1)
  end
  file.close

  tag_first = Tag.find(:first).id
  tag_last = Tag.find(:last).id

  USERS = 1000000

  puts "Inserting users into database..."
  # Add bunch of users
  (USERS/1000).times do |u_num|
    #Break up user inserts into 1000 row insert transactions to speed them up
    ActiveRecord::Base.transaction do
      1000.times do |i|
        uid = u_num*1000+i
        insert_1 = "INSERT INTO users (name,fb_id,friend_hash,created_at,updated_at) VALUES ('User_#{(uid+1).to_s}',#{uid}, 'bob', NOW(), NOW())"
        ActiveRecord::Base.connection.execute(insert_1)
      end
    end
    puts "Inserted #{u_num*1000} users"
  end

  first_user = User.find(:first).id
  last_user = User.find(:last).id

  puts "Inserting torrents into database..."
  (USERS/1000).times do |t_num|
    #Break up torrent inserts into 1000 row insert transactions to speed them up
    ActiveRecord::Base.transaction do
      1000.times do |i|
        tid = t_num*1000+i
        uid = first_user+tid
        insert_1 = "INSERT INTO torrents (name,size,meta_info, category_id,owner_id, data, info_hash,created_at,updated_at) VALUES ('#{uid.to_s}',1,'1',#{category_ids.shuffle[0]}, #{uid},'7',#{uid}, NOW(), NOW())"
        ActiveRecord::Base.connection.execute(insert_1)
       end
     puts "Inserted #{t_num*1000} torrents" 
     end
   end

  first_torrent = Torrent.find(:first).id
  last_torrent = Torrent.find(:last).id

  puts "Inserting tags for torrents into database..."
  (USERS/1000).times do |tag_num|
    #Break up tag inserts into 1000 row insert transactions to speed them up
    ActiveRecord::Base.transaction do
      1000.times do |i|
        tid = tag_num*1000+i
        torrentid = first_torrent+tid
        tags = []
        until tags.length == 3 do
          tags << tag_first+rand(5000) 
          tags = tags.uniq
        end
        insert_1 = "INSERT INTO taggings (tag_id, taggable_id, taggable_type, created_at) VALUES ('#{tags[0]}', #{torrentid}, 'Torrent',NOW())"
        ActiveRecord::Base.connection.execute(insert_1)
        insert_2 = "INSERT INTO taggings (tag_id, taggable_id, taggable_type, created_at) VALUES ('#{tags[1]}',#{torrentid}, 'Torrent',NOW())"
        ActiveRecord::Base.connection.execute(insert_2)
        insert_3 = "INSERT INTO taggings (tag_id, taggable_id, taggable_type, created_at) VALUES ('#{tags[2]}',#{torrentid}, 'Torrent',NOW())"
        ActiveRecord::Base.connection.execute(insert_3)
      end
      puts "Inserted #{tag_num*1000} tags"
    end
   end

  puts "Inserting swarm entries into database..."
  (USERS/1000).times do |s_num|   
    #Break up swarm inserts into 1000 row insert transactions to speed them up
    ActiveRecord::Base.transaction do
      1000.times do |i|
        next if rand(5) < 3
        id = s_num*1000+i
        userid = first_user+id
        torrentid = first_torrent+id
        insert_1 = "INSERT INTO swarms (user_id,torrent_id, ip_address, port, peer_id, status, created_at, updated_at) VALUES ('#{userid}', #{torrentid}, '192.168.0.1', '6060', #{rand(100000)}, 0, NOW(), NOW())"
        ActiveRecord::Base.connection.execute(insert_1)
      end
    end
    puts "Inserted #{s_num*1000} swarms"      
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
  
  first_torrent = Torrent.find(:first).id
  last_torrent = Torrent.find(:last).id
  first_user = User.find(:first).id
  last_user = User.find(:last).id

  num_users = last_user-first_user
  num_torrents = last_torrent-first_torrent

  #Generate 1000 valid announce urls
  50000.times do |i|
    #pick random a random torrent and random user
    u = User.find(first_user+rand(num_users))
    t = Torrent.find(first_torrent+rand(num_torrents))
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

