class SwarmsController < ApplicationController
  require 'bencode'

  def announce
    # TODO: make a way to get torrent ids
    unless params[:peer_id] && params[:port]
      render :text => {"failure" => "Not enough parameters sent!"}.bencode, :status => 500
      return
    end
    torrent_id = 1
    event = params[:event] || "empty"
    ip = params[:ip] || request.remote_ip
    if event == "stopped"
      Swarm.delete_swarm(torrent_id, params[:peer_id], ip, params[:port])
      render :text => ""
      return
    end

    Swarm.add_to_swarm(torrent_id, params[:peer_id], ip, params[:port]) if event == "started"
    swarm = Swarm.get_swarm_list torrent_id, (params[:numwant] || 50)
    swarm.collect! do |s|
      {"id" => "TODO", "ip" => s.ip_address, "port" => s.port}
    end
    
    output = {"interval" => 30, "peers" => swarm}
    render :text => output.bencode    
  end

end
