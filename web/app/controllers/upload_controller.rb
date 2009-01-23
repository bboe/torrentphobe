class UploadController < ApplicationController
      def index
         @uploaded = "Not_uploaded"
         render :file => 'app\views\upload\uploadTorrent.rhtml'
      end
      def uploadTorrent
        post = TorrentFile.save(params[:upload])
        @uploaded = "uploaded"
        render :file => 'app\views\upload\uploadTorrent.rhtml'
        #render :file => 'app\views\upload\uploadTorrent.rhtml'
        #render :text => "File has been uploaded successfully"
      end
    
end
