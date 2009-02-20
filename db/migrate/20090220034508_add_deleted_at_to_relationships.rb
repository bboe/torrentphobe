class AddDeletedAtToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :deleted_at, :datetime
  end

  def self.down
    remove_column :relationships, :deleted_at
  end
end
