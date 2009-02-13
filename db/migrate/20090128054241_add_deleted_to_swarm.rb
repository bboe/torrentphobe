class AddDeletedToSwarm < ActiveRecord::Migration
  def self.up
    add_column :swarms, :deleted, :boolean
  end

  def self.down
    remove_column :swarms, :deleted
  end
end
