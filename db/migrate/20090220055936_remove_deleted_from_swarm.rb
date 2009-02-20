class RemoveDeletedFromSwarm < ActiveRecord::Migration
  def self.up
    remove_column :swarms, :deleted
  end

  def self.down
    add_column :swarms, :deleted, :boolean
  end
end
