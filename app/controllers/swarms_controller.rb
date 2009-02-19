class SwarmsController < ApplicationController
  require 'bencode'
  require 'openssl'
  require 'ezcrypto'

  def announce
    params[:id] = params[:id].join("/") if params[:id]
    unless params[:peer_id] && params[:port] && params[:id]
      render :text => {"failure" => "Not enough parameters sent!"}.bencode, :status => 500
      return
    end

    decrypted = get_user_and_torrent_or_false params[:id]
    unless decrypted
      render :text => {"failure" => "Invalid announce URL."}.bencode, :status => 500
      return
    end

    user_id, torrent_id = decrypted
    event = params[:event] || "empty"
    ip = params[:ip] || request.remote_ip
    
    event = "completed" if( event == "started" and params[:left] == 0.to_s )
    
    Swarm.add_or_update_swarm(torrent_id, user_id, params[:peer_id], ip, params[:port], event)
    
    if event == "stopped" or event == "completed"
      render :text => ""
      return
    end

    swarm = Swarm.get_swarm_list torrent_id, user_id, (params[:numwant] || "50")
    swarm.collect! do |s|
      {"id" => s.peer_id, "ip" => s.ip_address, "port" => s.port}
    end
    
    output = {"interval" => 30, "peers" => swarm}
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
