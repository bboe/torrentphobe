require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "missing fields" do
       user = users(:Jonathan)
       assert user.valid?
       user.name = nil
       assert !user.valid?
       user.name="Jon"
      user.friend_hash = nil
      assert !user.valid?
      user.friend_hash = "7000"
      user.fb_id = nil
      assert !user.valid?
  end
    test "negative ID"  do
        user = users(:Shashank)
        user.fb_id = 0
        assert !user.valid?
    end
    test "add friend" do
        user1 = users(:Jonathan)
        user2 = users(:Shashank)
        assert_difference('Relationship.count', 2) do
            user1.add_friend(user2)    
        end
        assert (user1.friends.include? user2)
        assert (user2.friends.include? user1)       
    end
    test "duplicates" do
       user1 = users(:Jonathan)
       user2 = users(:Shashank)
                                                    \
       assert_difference('Relationship.count', 2) do
          user1.add_friend(user2)
       end
       assert_difference('Relationship.count', 0) do
          user1.add_friend(user2)
       end
    end
end
