class CreateSwarms < ActiveRecord::Migration
  def self.up
    create_table :swarms, :options => "ENGINE=MEMORY" do |t|
      t.integer :user_id
      t.integer :torrent_id
      t.string :ip_address
      t.integer :port

      t.timestamps
    end
  end

  def self.down
    drop_table :swarms
  end
end
