class TorrentsController < ApplicationController
  layout 'main'

  before_filter :login_required

  # GET /torrents
  # GET /torrents.xml
  def index
    current_user = get_current_user
    @torrents = current_user.available_torrents
    @torrents = Category.sort_torrents(@torrents, params[:c], params[:d])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.xml
  def show
    return if invalid_id params[:id]
    current_user = get_current_user

    @torrent = Torrent.find(params[:id])

    return if not_friends_or_owner current_user, @torrent

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

    #if !has_valid_content_type(params[:torrent][:torrent_file])
    #  return invalid_create "Umm, that definately was not a torrent file"
    #end

    begin
      @torrent.encode_data
    rescue BEncode::DecodeError
      return invalid_create "Yikes, that torrent was not valid"
    end


    @torrent.tag_list.add(create_automatic_tags(@torrent.name)) if !@torrent.name.nil?
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
    current_user = get_current_user
    return if not_friends_or_owner current_user, @torrent

    user_id = current_user.id
    unless request.env["HTTP_HOST"][0..7] == "http://"
      request.env["HTTP_HOST"] = "http://" + request.env["HTTP_HOST"]
    end
    host_url = request.env["HTTP_HOST"]
    send_data @torrent.generate_torrent_file( user_id, host_url ), :filename => @torrent.filename
  end

  def search
    @query = params[:q].to_s
    @torrents = Torrent.find_by_contents(@query)

    current_user = get_current_user
    @available_torrents = current_user.available_torrents

    @torrents.map! { |torrent| torrent if @available_torrents.include?(torrent) }.compact!
    @torrents = Category.sort_torrents(@torrents, params[:c], params[:d])

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
    tags.map!{ |tag| tag if tag.length > 1 }
  end

  def invalid_create message
    flash[:warning] = message
    logger.error("Attempt to create invalid torrent by user #{session[:user_id]}" )
    redirect_to :action => :new
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

  def not_friends_or_owner user, torrent
    if torrent.owner.id != user.id and !user.friends.find_by_id( torrent.owner.id )
      display_message :warning, torrent.id, "Sorry, you must be somones friend to see their torrents!"
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
