class Torrent < ActiveRecord::Base
  validates_presence_of :name, :size, :meta_info
  validates_numericality_of :size, :greater_than => 0
  def self.updatetorrentfile(upload)
     @tempname = upload['torrentfile'].original_filename
     @tempsize = upload['torrentfile'].size
     @tempmeta_info = 10
     @tempdata = upload['torrentfile'].read    
  end

end
