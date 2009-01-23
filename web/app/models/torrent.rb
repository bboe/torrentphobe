class Torrent < ActiveRecord::Base
  validates_presence_of :name, :size, :meta_info
  validates_numericality_of :size, :greater_than => 0
end
