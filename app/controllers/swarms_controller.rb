class SwarmsController < ApplicationController
  require 'bencode'
  require 'openssl'
  require 'ezcrypto'

  def a #announce needed to be renamed since we don't have scrape
    params[:id] = params[:id].join("/") if params[:id]
    unless(params[:peer_id] && params[:ip] && params[:port] && params[:id] &&
           params[:info_hash])
      render :text => {"failure" => "Not enough parameters sent!"}.bencode, :status => 500
      return
    end

    decrypted = get_user_and_torrent_or_false params[:id]
    unless decrypted
      render :text => {"failure" => "Invalid announce URL."}.bencode, :status => 500
      return
    end

    user_id, torrent_id = decrypted
    # FIXME
    info_hash = Torrent.find_by_id(torrent_id).info_hash
    if info_hash != params[:info_hash]
      render :text => {"failure" => "Announce URL is not valid for this torrent."}.bencode, :status => 500
      return      
    end

    event = params[:event] || "empty"
    ip = params[:ip] || request.remote_ip
    
    event = "completed" if( event == "started" and params[:left] == 0.to_s )

    updated = Swarm.add_or_update_swarm(torrent_id, user_id, params[:peer_id], ip, params[:port], event)

    if !updated
      render :text => {"failure" => "Bad Request."}.bencode, :status => 400
      return
    end 
    
    if event == "stopped"
      render :text => ""
      return
    end

    swarm = Swarm.get_swarm_list torrent_id, user_id, (params[:numwant] || "50")
    swarm.collect! do |s|
      {"peer id" => s.peer_id, "ip" => s.ip_address, "port" => s.port}
    end
    
    output = {"interval" => 30, "peers" => swarm, "complete" => Swarm.get_seeders(torrent_id), "incomplete" => Swarm.get_leechers(torrent_id)}
    render :text => output.bencode    
  end


  private

  def get_user_and_torrent_or_false encrypted_base64
    begin
      decrypted = Torrent::KEY.decrypt64(encrypted_base64 + "==\n")
    rescue OpenSSL::Cipher::CipherError
      return false
    end
    return false unless decrypted.match('[0-9]+/[0-9]+')
    return decrypted.split('/')
  end
end
