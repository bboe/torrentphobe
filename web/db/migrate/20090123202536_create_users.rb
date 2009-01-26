<<<<<<< HEAD:web/db/migrate/20090123202536_create_users.rb
=======
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
>>>>>>> 932f41c531bd4c5d763033807dfdbb01e2702d14:web/db/migrate/20090123202536_create_users.rb
