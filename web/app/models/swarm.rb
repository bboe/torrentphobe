class Swarm < ActiveRecord::Base
  validates_presence_of :user_id, :torrent_id, :ip_address, :port
  validates_numericality_of :port, :greater_than => 0, :less_than => 65536
  validate :ip_address_is_valid

  protected 
  def ip_address_is_valid
    m = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/.match(ip_address.to_s)
    unless m
      errors.add(:ip_address, "IP address must be in the form XXX.XXX.XXX.XXX")
      return
    end
    octects = m.captures
    if octects.length == 4
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
