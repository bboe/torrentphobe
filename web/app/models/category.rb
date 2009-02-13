class Category < ActiveRecord::Base
  has_many :torrents
  acts_as_ferret :fields => [:name]

  def self.sort_torrents(torrents, category, direction)
    if torrents
       case category
       when "category_id"
	  torrents = torrents.sort_by { |torrent| torrent.category_id } 
       when "size"
	  torrents = torrents.sort_by { |torrent| torrent.size } 
       else
	  torrents = torrents.sort_by { |torrent| torrent.name.downcase } 
       end
       if direction == "up"
	 torrents = torrents.reverse
       end
    else
      torrents = []
    end
    torrents
  end
end
