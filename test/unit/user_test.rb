require 'test/test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "missing fields" do
    user = users(:Jonathan)
    assert user.valid?

    user.name = nil
    assert !user.valid?
    user.name="Jonathan"

    user.friend_hash = nil
    assert !user.valid?
    user.friend_hash = "7000"

    user.fb_id = nil
    assert !user.valid?
  end

  test "negative fb_id"  do
    user = users(:Shashank)
    user.fb_id = -1
    assert !user.valid?

    user.fb_id = 0
    assert !user.valid?
  end

  test "add friend" do
    jonathan = users(:Jonathan)
    shashank = users(:Shashank)

    assert_difference('Relationship.count', 2) do
      jonathan.add_friend(shashank)
    end

    #relationship should be bi-drectional
    assert (jonathan.friends.include? shashank)
    assert (shashank.friends.include? jonathan)
  end

  test "duplicate relationships" do
    jonathan = users(:Jonathan)
    shashank = users(:Shashank)

    assert_difference('Relationship.count', 2) do
      shashank.add_friend(jonathan)
    end

    #bi-directional relationship already created, should not be added again
    assert_difference('Relationship.count', 0) do
      jonathan.add_friend(shashank)
    end
  end

  test "bittorrent seeding/download users" do
    jon = users(:Jonathan)
    good = torrents(:good)
    assert_equal [good], jon.torrents
  end

  test "display my torrents, but not display enemies' torrents" do
    tom = users(:Tom)
    jerry = users(:Jerry)

    toms_torrents = tom.torrents 
    jerrys_torrents = jerry.torrents

    #don't show enemies'
    assert !(jerrys_torrents.include?( toms_torrents) ), "Jerry can see tom's torrents"

    #display our owned torrents
    assert (toms_torrents.include?( torrents("toms"))), "tom sees his own torrents" 
    assert (jerrys_torrents.include?( torrents("jerrys"))), "jerry sees his own torrents"
  end

  test "display friends' torrents " do
     tom = users(:Tom)
     jerry = users(:Jerry)
     assert_difference("Relationship.count", 2) do
       tom.add_friend(jerry)
     end
     assert tom.friends.include?( jerry ), "tom and jerry are friends"  
     assert tom.torrents.include? torrents("jerrys")
  end

  test "get friends' owned torrents" do
    tom = users(:Tom)
    jerry = users(:Jerry)
    assert_difference("Relationship.count", 2) do
      tom.add_friend(jerry)
    end
    test = Torrent.create(:name => "test", :size => 1, :meta_info => "info", :data => "more data", :category_id => 1, :owner_id => jerry.id)
    Swarm.add_user_to_swarm_for_list test.id, test.owner_id
    test.save
    assert tom.torrents.include? test
  end

  test "view torrents through friends" do
    tom = users(:Tom)
    jerry = users(:Jerry)
    bob = users(:Bob)
    assert_difference("Relationship.count", 2) do
      bob.add_friend(jerry)
    end
    assert_difference("Relationship.count", 2) do
      bob.add_friend(tom)
    end

    #Cant see enemies torrents
    assert !tom.torrents.include?(torrents(:jerrys))

    Swarm.add_or_update_swarm torrents(:jerrys).id, bob.id, "I'mAPeer", "127.0.0.1", "5050", "started"

    #Should be able to see enemies torrent becuase common friend is downloading it
    assert tom.torrents.include? torrents(:jerrys)
  end

  test "view torrents paginated" do
    alice = users(:Alice)
    bob = users(:Bob)
    50.times do |i|
      #prepend zeros before the name so that it sorts correctly by digit
      name = "000" + (i < 10 ? "0"+i.to_s : i.to_s )
      test = Torrent.create(:name => name, :size => 1, :meta_info => "info", :info_hash => i.to_s, :data => "more data", :category_id => 1, :owner_id => alice.id)
      Swarm.add_or_update_swarm test.id, alice.id, "I'mAPeer", "127.0.0.1", "5050", "stopped"
    end

    #By default 20 torrents should be returned from the first page
    assert_equal 20, bob.torrents(:limit => 20).length

    #By default 20 torrents should be returned from the second page
    assert_equal 20, bob.torrents(:limit => 20, :offset => 20).length

    #Return the second page of 5 torrents (torrents 5-9)
    second_five = bob.torrents(:offset => 5, :limit => 5, :order => "name ASC")
    assert_equal 5, second_five.length

    id = 5
    #Ensure that torrents 5-9 are returned (as identified by their name)
    second_five.each do |torrent|
      assert_equal torrent.name.to_i, id, "Look up torrents by page, second five"
      id+=1
    end
    
    #Return the last page of 10 torrents (torrents 40-49)
    last_five = bob.torrents(:offset => 40, :limit => 10, :order => "name ASC")

    assert_equal 10, last_five.length

    id = 40
    #Ensure that torrents 5-9 are returned (as identified by their name)
    last_five.each do |torrent|
      assert_equal torrent.name.to_i, id, "Look up torrents by page, last ten"
      id+=1
    end
  end

  test "delete users" do
    tom = users(:Tom)
    assert_difference("User.count", -1) do
      tom.delete
      tom.save
    end
    assert !User.exists?(tom.id)
    u = User.find_by_sql("select * from users where id = " + tom.id.to_s)[0]
    assert_equal tom, u        
  end

  test "torrents with conditions" do
    tom = users(:Tom)
    assert_equal [torrents(:toms)], (tom.torrents :conditions => ["category_id = :category_id", {:category_id => 1}])
  end

  test "count torrents" do
    bob = users(:Bob)
    #The count of torrents should be the same as the length of the torrent list
    assert_equal bob.torrents.length, bob.torrent_count
  end
  
end
