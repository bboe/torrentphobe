class AddCategoryToTorrents < ActiveRecord::Migration
  def self.up
    add_column :torrents, :category_id, :int
  end

  def self.down
    remove_column :torrents, :category_id
  end
end
