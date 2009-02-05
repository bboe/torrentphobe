class Category < ActiveRecord::Base
  has_many :torrents
  acts_as_ferret :fields => [:name]
end
