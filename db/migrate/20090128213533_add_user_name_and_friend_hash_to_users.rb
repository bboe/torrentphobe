class AddUserNameAndFriendHashToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :friend_hash, :string
  end

  def self.down
    remove_column :users, :friend_hash
    remove_column :users, :name
  end
end
