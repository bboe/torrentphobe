class AddUserIdIndexToSwarms < ActiveRecord::Migration
  def self.up
        add_index :swarms, [:user_id]
  end

  def self.down
  end
end
