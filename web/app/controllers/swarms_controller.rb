class SwarmsController < ApplicationController
  require 'bencode'

  def announce
    unless params[:peer_id] && params[:port] && params[:encrypted64]
      render :text => {"failure" => "Not enough parameters sent!"}.bencode, :status => 500
      return
    end

    decrypted = get_user_and_torrent_or_false params[:encrypted64]
    unless decrypted
      render :text => {"failure" => "Invalid announce URL."}.bencode, :status => 500
      return
    end

    user_id, torrent_id = decrypted
    event = params[:event] || "empty"
    ip = params[:ip] || request.remote_ip
    if event == "stopped"
      Swarm.delete_swarm(torrent_id, user_id, params[:peer_id], ip, params[:port])
      render :text => ""
      return
    end

    Swarm.add_to_swarm(torrent_id, user_id, params[:peer_id], ip, params[:port]) if event == "started"

    swarm = Swarm.get_swarm_list torrent_id, user_id, (params[:numwant] || 50)
    swarm.collect! do |s|
      {"id" => s.peer_id, "ip" => s.ip_address, "port" => s.port}
    end
    
    output = {"interval" => 30, "peers" => swarm}
    render :text => output.bencode    
  end


  private

  def get_user_and_torrent_or_false encrypted_base64
    decrypted = Torrent::KEY.decrypt64(encrypted_base64 + "==\n")
    return False unless decrypted.match('[0-9]+/[0-9]+')
    return decrypted.split('/')
  end
end
