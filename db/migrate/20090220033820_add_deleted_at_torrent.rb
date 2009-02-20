class AddDeletedAtTorrent < ActiveRecord::Migration
  def self.up
    add_column :torrents, :deleted_at, :datetime
  end

  def self.down
    remove_column :torrents, :deleted_at
  end
end
