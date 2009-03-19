class Swarm < ActiveRecord::Base

  belongs_to :torrent
  belongs_to :user

  validates_presence_of :user_id, :torrent_id, :ip_address, :port, :peer_id
  validates_numericality_of :port, :greater_than => 0, :less_than => 65536
  validate :ip_address_is_valid

  def self.get_swarm_list torrent_id, user_id, num_want = 50
    self.find_by_sql(["select * from (select swarms.* from swarms, relationships where (relationships.friend_id = swarms.user_id and relationships.user_id = :user_id and swarms.torrent_id = :torrent_id and status != :status) UNION select swarms.* from swarms where (swarms.torrent_id = :torrent_id and swarms.user_id = :user_id and status != :status)) as swarms limit :num_want", {:user_id => user_id, :torrent_id => torrent_id, :num_want => num_want.to_i, :status => 2}])
  end

  def self.add_or_update_swarm torrent_id, user_id, peer_id, ip, port, status
    t = Swarm.find_or_initialize_by_user_id_and_torrent_id_and_ip_address_and_port({
          :user_id => user_id, :torrent_id => torrent_id,
          :ip_address => ip, :port => port
           })

    t.status = Swarm.get_status_id("started") if(t.status.nil? or t.status == Swarm.get_status_id("stopped"))
    t.status = Swarm.get_status_id(status) if !Swarm.get_status_id(status).nil?
    t.peer_id = peer_id
    return t.save
  end

  # FIXME - this is really a hack
  # Doesn't set status properly for some strange reason
  def self.add_user_to_swarm_for_list torrent_id, user_id
    Swarm.find_or_create_by_user_id_and_torrent_id_and_ip_address_and_port :torrent_id => torrent_id, :user_id => user_id, :peer_id => "_", :port => 1, :ip_address => "127.0.0.1", :status => 2
  end

  def self.get_seeders(torrent_id, user_id)
    Swarm.get_seeders_or_leechers_count torrent_id, user_id, Swarm.get_status_id("completed")
  end

  def self.get_leechers(torrent_id, user_id)
    Swarm.get_seeders_or_leechers_count torrent_id, user_id, Swarm.get_status_id("started")
  end

  def self.get_all_seeders user_id
    Swarm.get_all_seeders_or_leechers user_id, Swarm.get_status_id("completed")
  end

  def self.get_all_leechers user_id
    Swarm.get_all_seeders_or_leechers user_id, Swarm.get_status_id("started")
  end

  protected

  def self.get_all_seeders_or_leechers user_id, status
    s_or_l = Swarm.find_by_sql(["select count(x.torrent_id) as id, x.torrent_id from (select swarms.torrent_id, swarms.id from swarms, relationships where swarms.user_id = relationships.user_id and relationships.friend_id = :user_id and swarms.status = :status UNION select swarms.torrent_id, swarms.id from swarms where swarms.status = :status and swarms.user_id = :user_id) as x group by x.torrent_id", {:status => status, :user_id => user_id}]);
    hash = Hash.new(0)
    s_or_l.each{|x| hash[x.torrent_id] = x.id}
    return hash
  end
  
  def self.get_seeders_or_leechers_count torrent_id, user_id, status
    Swarm.count_by_sql( ["select count(x.torrent_id) from (select swarms.torrent_id, swarms.id from swarms, relationships where swarms.user_id = relationships.user_id and relationships.friend_id = :user_id and swarms.status = :status  and swarms.torrent_id = :torrent_id UNION select swarms.torrent_id, swarms.id from swarms where swarms.status = :status and swarms.user_id = :user_id and swarms.torrent_id = :torrent_id) as x", {:status => status, :user_id => user_id, :torrent_id => torrent_id}])
  end

  def self.get_status_id input
    case input
    when "started"
      return 0
    when "completed"
      return 1
    when "stopped"
      return 2
    else
      return nil
    end
  end

 
  def ip_address_is_valid
    m = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.match(ip_address.to_s)
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
