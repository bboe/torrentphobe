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
end
