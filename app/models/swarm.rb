class Swarm < ActiveRecord::Base

  belongs_to :torrent
  belongs_to :user

  validates_presence_of :user_id, :torrent_id, :ip_address, :port, :peer_id
  validates_numericality_of :port, :greater_than => 0, :less_than => 65536
  validate :ip_address_is_valid

  def self.get_swarm_list torrent_id, user_id, num_want = 50
    swarm = self.find(:all, 
                      :conditions => ["torrent_id = :torrent_id and status != 2",
                                      {:torrent_id => torrent_id}],
                      :limit => num_want)

    friends = Relationship.find(:all, 
                                :select => "friend_id", 
                                :conditions => ["user_id = :user_id", {:user_id => user_id}]
                                ).map(&:friend_id)

    friends << user_id.to_i
    #Do not include users who are not friends with the input user into the swarm list
    swarm = swarm.map { |swarm_user| swarm_user if( friends.include?(swarm_user.user_id) ) }.compact
  end

  def self.add_or_update_swarm torrent_id, user_id, peer_id, ip, port, status
    t = Swarm.find_or_create_by_user_id_and_torrent_id_and_ip_address_and_port({
          :user_id => user_id, :torrent_id => torrent_id,
          :ip_address => ip, :port => port
           })
    t.status = Swarm.get_status_id(status)
    t.peer_id = peer_id
    t.deleted = status=="stopped"
    t.save
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
      return 1
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
