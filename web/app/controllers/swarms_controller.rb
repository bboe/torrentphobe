class SwarmsController < ApplicationController
  require 'bencode'

  def announce
    unless params[:peer_id] && params[:port] && params[:hash] && params[:torrent_id] && params[:user_id]
      render :text => {"failure" => "Not enough parameters sent!"}.bencode, :status => 500
      return
    end
    
    unless good_hash? params[:hash], params[:torrent_id], params[:user_id]
      render :text => {"failure" => "Invalid announce URL."}.bencode, :status => 500
      return
    end


    torrent_id = params[:torrent_id]
    user_id = params[:user_id]
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

  def good_hash? hash, torrent_id, user_id
    Digest::SHA1.hexdigest(torrent_id.to_s + Torrent::SECRECT_KEY + user_id.to_s) == hash
  end
end
