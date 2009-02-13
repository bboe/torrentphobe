class AddPeerIdToSwarm < ActiveRecord::Migration
  def self.up
    add_column :swarms, :peer_id, :string
  end

  def self.down
    remove_column :swarms, :peer_id
  end
end
