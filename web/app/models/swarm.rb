class Swarm < ActiveRecord::Base
  validates_presence_of :user_id, :torrent_id, :ip_address, :port, :peer_id
  validates_numericality_of :port, :greater_than => 0, :less_than => 65536
  validate :ip_address_is_valid

  def self.get_swarm_list torrent_id, num_want = 50
    self.find(:all, 
              :conditions => ["torrent_id = :torrent_id",
                              {:torrent_id => torrent_id}],
              :limit => num_want)
  end

  def self.add_to_swarm torrent_id, peer_id, ip, port
    Swarm.create({:user_id => 1, :torrent_id => torrent_id, :peer_id => peer_id, :ip_address => ip, :port => port})
  end

  def self.delete_swarm torrent_id, peer_id, ip, port
    # TODO: Implement delete swarm
  end

  protected 
  def ip_address_is_valid
    m = /^(\d{1,3})\.(\d{1,3})\.(\d{1,2})\.(\d{1,3})$/.match(ip_address.to_s)
    unless m
      errors.add(:ip_address, "IP address must be in the form XXX.XXX.XXX.XXX")
      return
    end
    octects = m.captures
    if octects.length == 4
    then
      octects.each do |octect|
        if Integer(octect) < 0 || Integer(octect) > 255
          errors.add(:ip_address, "Each octect must be between 0 and 255")
        end
      end
    else
      errors.add(:ip_address, "IP address must be in the form XXX.XXX.XXX.XXX")
    end        
  end  
end