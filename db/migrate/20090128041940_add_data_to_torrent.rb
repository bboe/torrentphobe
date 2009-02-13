class AddDataToTorrent < ActiveRecord::Migration
  def self.up
    remove_column :torrents, :meta_info
    add_column :torrents, :meta_info, :string
    add_column :torrents, :data, :binary
  end

  def self.down
    remove_column :torrents, :data
    remove_column :torrents, :meta_info
    add_column :torrents, :meta_info, :binary
  end
end
