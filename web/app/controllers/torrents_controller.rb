class TorrentsController < ApplicationController
  layout 'main'

  # GET /torrents
  # GET /torrents.xml
  def index
    @torrents = Torrent.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.xml
  def show
     begin
         @torrent = Torrent.find(params[:id])
     rescue ActiveRecord::RecordNotFound
         logger.error("Attempt to access invalid torrent #{params[:id]}" )
         flash[:notice] = "Whoops, thats not a valid torrent!"
         redirect_to :action => :index
     else
         respond_to do |format|
             format.html # show.html.erb
             format.xml  { render :xml => @torrent }
          end
     end
  end

  # GET /torrents/new
  # GET /torrents/new.xml
  def new
    @torrent = Torrent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @torrent }
    end
  end

  # GET /torrents/1/edit
  def edit
    begin
        @torrent = Torrent.find(params[:id])
     rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid torrent #{params[:id]}" )
        flash[:notice] = "Whoops, thats not a valid torrent!"
        redirect_to :action => :index
     end
  end

  # POST /torrents
  # POST /torrents.xml
  def create
    @torrent = Torrent.new(params[:torrent])
    user = User.find(session[:user_id])
    @torrent.owner = user
    if has_valid_content_type(params[:torrent][:torrent_file])
      begin
        @torrent.encode_data
      rescue BEncode::DecodeError
        @torrent.data = nil
      end
    end

    @torrent.tag_list.add(create_automatic_tags(@torrent.name))
    respond_to do |format|
      if @torrent.save
        flash[:notice] = 'Torrent was successfully created.'
        format.html { redirect_to(@torrent) }
        format.xml  { render :xml => @torrent, :status => :created, :location => @torrent }
      else
        flash[:error] = "Torrent was not created successfully."
        format.html { render :action => "new" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /torrents/1
  # PUT /torrents/1.xml
  def update
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      if @torrent.update_attributes(params[:torrent])
        flash[:notice] = 'Torrent was successfully updated.'
        format.html { redirect_to(@torrent) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.xml
  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy

    respond_to do |format|
      format.html { redirect_to(torrents_url) }
      format.xml  { head :ok }
    end
  end

  def download_torrent_file
    @torrent = Torrent.find(params[:id])
    user_id = session[:user_id]
    send_data @torrent.generate_torrent_file( user_id ), :filename => @torrent.filename
  end

  def search
    @query = params[:q].to_s
    @torrents = Torrent.find_by_contents(@query)

    respond_to do |format|
       format.html { render :action => "search" }
       format.xml  { head :ok }
    end
  end

  protected
  def has_valid_content_type file
    file.content_type.chomp == "application/x-bittorrent"
  end

  def create_automatic_tags name
    tags = name.gsub(/[-._()\]\[]/," ").split
  end

end
