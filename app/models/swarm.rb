class Swarm < ActiveRecord::Base

  belongs_to :torrent
  belongs_to :user

  validates_presence_of :user_id, :torrent_id, :ip_address, :port, :peer_id
  validates_numericality_of :port, :greater_than => 0, :less_than => 65536
  validate :ip_address_is_valid

  def self.get_swarm_list torrent_id, user_id, num_want = 50
    self.find(:all, 
              :conditions => ["torrent_id = :torrent_id and deleted = 'f' and status != 2",
                              {:torrent_id => torrent_id}],
              :limit => num_want)
  end

  def self.add_to_swarm torrent_id, user_id, peer_id, ip, port, status
    t = Swarm.find_or_create({:user_id => user_id, :torrent_id => torrent_id, :peer_id => peer_id, :ip_address => ip, :port => port})
    t.status = Swarm.get_status_id(status)
    t.deleted = false
    t.save
  end

  def self.update_swarm torrent_id, user_id, peer_id, ip, port, status
    s = Swarm.find(:first,
               :conditions => ["torrent_id = :torrent_id and peer_id = :peer_id and ip_address = :ip and port = :port and user_id = :user_id",
                               {:torrent_id => torrent_id, :peer_id => peer_id, :ip => ip, :port => port, :user_id => user_id}])
    if s
      s.status = Swarm.get_status_id(status)
      s.save
    end
  end

  def self.get_seeders torrent_id
    Swarm.count( :conditions => [ "torrent_id = ? and status = ?", torrent_id, Swarm.get_status_id("completed")] )
  end

  def self.get_leechers torrent_id
    Swarm.count( :conditions => [ "torrent_id = ? and status = ?", torrent_id, Swarm.get_status_id("started")] )
  end


  protected

  def self.get_status_id input
    case input
    when "started"
      return 0
    when "completed"
      return 1
    when "stopped"
      return 2
    else
      return -1
    end
  end

 
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
