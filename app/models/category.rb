class Category < ActiveRecord::Base
  has_many :torrents

  def self.sort_torrents(torrents, category, direction)
    if torrents
       case category
       when "category"
         torrents = torrents.sort_by { |torrent| torrent.category.name } 
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
