class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :fb_id

      t.timestamps
    end
    add_index :users, :fb_id, :unique => true
  end

  def self.down
    drop_table :users
  end
end
