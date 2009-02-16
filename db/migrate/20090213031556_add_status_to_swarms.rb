class AddStatusToSwarms < ActiveRecord::Migration
  def self.up
    add_column :swarms, :status, :integer
  end

  def self.down
    remove_column :swarms, :status
  end
end
