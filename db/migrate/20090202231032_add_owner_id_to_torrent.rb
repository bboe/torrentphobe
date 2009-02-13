class AddOwnerIdToTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :owner_id, :integer
  end

  def self.down
    remove_column :torrents, :owner_id
  end
end
