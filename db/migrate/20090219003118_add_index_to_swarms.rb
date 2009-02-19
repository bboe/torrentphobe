class AddIndexToSwarms < ActiveRecord::Migration
  def self.up
    add_index :swarms, [:user_id, :torrent_id, :ip_address, :port], :unique => true
  end

  def self.down
  end
end
