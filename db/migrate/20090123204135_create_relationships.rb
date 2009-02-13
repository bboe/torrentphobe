class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id
      t.integer :friend_id

      t.timestamps
    end
    add_index :relationships, [:user_id, :friend_id], :unique => true
  end

  def self.down
    drop_table :relationships
  end
end
