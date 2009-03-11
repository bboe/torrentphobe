class AddFriendIdIndex < ActiveRecord::Migration
  def self.up
	add_index :relationships, [:friend_id]
  end

  def self.down
  end
end
