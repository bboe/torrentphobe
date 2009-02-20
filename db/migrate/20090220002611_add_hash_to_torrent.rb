class AddHashToTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :info_hash, :binary, :limit => 20, :unique => true
  end

  def self.down
    remove_column :torrents, :info_hash
  end
end
