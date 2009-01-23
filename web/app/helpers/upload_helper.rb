module UploadHelper
  def save(upload)
    name =  upload['torrentfile'].original_filename
    directory = "public/torrents"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['torrentfile'].read) }
  end
end
