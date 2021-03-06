# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090220055936) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "relationships", ["user_id", "friend_id"], :name => "index_relationships_on_user_id_and_friend_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "swarms", :force => true do |t|
    t.integer  "user_id"
    t.integer  "torrent_id"
    t.string   "ip_address"
    t.integer  "port"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "peer_id"
    t.integer  "status"
  end

  add_index "swarms", ["user_id", "torrent_id", "ip_address", "port"], :name => "index_swarms_on_user_id_and_torrent_id_and_ip_address_and_port", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "torrents", :force => true do |t|
    t.string   "name"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "meta_info"
    t.binary   "data"
    t.integer  "category_id"
    t.integer  "owner_id"
    t.binary   "info_hash",   :limit => 20
    t.datetime "deleted_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "fb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "friend_hash"
    t.datetime "deleted_at"
  end

  add_index "users", ["fb_id"], :name => "index_users_on_fb_id", :unique => true

end
