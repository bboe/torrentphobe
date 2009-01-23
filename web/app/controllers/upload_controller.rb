class UploadController < ApplicationController

  layout "main"
  def index
    @uploaded = "Not_uploaded"
  end

  def uploadTorrent
    post = TorrentFile.save(params[:upload])
    @uploaded = "uploaded"
    redirect_to(:action => "index")
  end
end
