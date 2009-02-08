class TorrentsController < ApplicationController
  layout 'main'

  # GET /torrents
  # GET /torrents.xml
  def index
    #@torrents = Torrent.find(:all)
    sort_by = params[:sort_by]
    sort_by ||= 'name' # for default sort
    if(sort_by == 'category')
        @torrents = Torrent.find(:all, :order => 'category_id')
    else
        @torrents = Torrent.find(:all, :order => sort_by)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.xml
  def show
    return if invalid_id params[:id]

    @torrent = Torrent.find(params[:id])
    respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @torrent }
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
    return if invalid_id params[:id]
    @torrent = Torrent.find(params[:id])

    return if not_owner @torrent.owner_id
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
    return if invalid_id params[:id]
    @torrent = Torrent.find(params[:id])

    return if not_owner @torrent.owner_id

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
    return if invalid_id params[:id]
    @torrent = Torrent.find(params[:id])

    return if not_owner @torrent.owner_id
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

  def invalid_id id
    if !Torrent.exists?(id)
      display_message :notice, id, "Whoops, thats not a valid torrent!"
    end
  end

  def not_owner id
    if session[:user_id] != id
      display_message :warning, id, "Hey, you cant change that torrent, its not yours!"
     end
  end

  def display_message type, torrent_id, message
    case type
      when :notice
        logger.error("Attempt to access invalid torrent #{torrent_id} by user #{session[:user_id]}" )
      when :warning
        logger.error("Attempt to modify a torrent without owner privilege #{torrent_id} by user #{session[:user_id]}" )
      else
        logger.error("Attempt to do something bad to torrent #{torrent_id} by user #{session[:user_id]}" )
    end
    flash[type] = message
    redirect_to :action => :index
  end
end
