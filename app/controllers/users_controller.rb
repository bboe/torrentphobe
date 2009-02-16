class UsersController < ApplicationController
  layout "main"

  require 'digest/md5'
  before_filter :login_required, :except => [:login, :logout]
  before_filter :set_facebook_session
  helper_method :facebook_session

  # GET /users
  # GET /users.xml
  def index
    current_user = get_current_user
    @users = current_user.friends

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    return if invalid_id params[:id]
    current_user = get_current_user
    return if not_friend_or_user( current_user, params[:id] )

    @user = User.find(params[:id])

    ordering = handle_sort params
    if current_user == @user
      @torrents = @user.my_torrents
    else
      @torrents = @user.torrents
    end

    @torrents.sort! { |a,b| a.created_at <=> b.created_at }
    @torrents = @torrents.reverse[0..5]

    respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
    end
  end

  def login
    friend_ids = facebook_session.user.friends.map { |user| user.uid }
    friend_hash = Digest::MD5.hexdigest( friend_ids.to_s )

    name = facebook_session.user.name

    @user = User.find_by_fb_id( facebook_session.user.uid )

    forced_update = false
    if !@user
      @user = User.new( { :fb_id => facebook_session.user.uid, :name => name, :friend_hash => friend_hash } )
      #new users should be forced to update to add their relationships, but only if they properly save
      forced_update = @user.save
    end

    if forced_update or @user.friend_hash != friend_hash or @user.name != name
        @user.update_info(friend_ids, name)
    end

    if @user.save
      session[:user_id] = @user.id
      session[:user_name] = @user.name
      flash[:message] = 'Welcome to torrentphobe '+@user.name
      redirect_to(@user)
    else
      flash[:notice] = 'User failed to log in.'
      redirect_to( :controller => :landing, :action => :index )
    end
  end

  def logout
    reset_session
    facebook_session = nil
    session[:user_id] = nil
    session[:user_name] = nil
    redirect_to(:controller => :landing, :action => :index)
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  # GET /users/1/edit
  def edit
    return if invalid_id params[:id]
    @user = User.find(params[:id])

    return if not_owner @user.id
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new({"fb_id" =>  params[:user]["fb_id"]})
    @user.save()

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    return if invalid_id params[:id]
    @user = User.find(params[:id])

    return if not_owner @user.id

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    return if invalid_id params[:id]
    @user = User.find(params[:id])

    return if not_owner @user.id
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def files
    return if invalid_id params[:id]
    current_user = get_current_user
    return if not_friend_or_user current_user, params[:id]

    @user = User.find(params[:id])

    ordering = handle_sort params
    if current_user == @user
      @torrents = @user.my_torrents
    else
      @torrents = @user.torrents
    end

    respond_to do |format|
      format.html # files.html.erb
      format.xml
    end
  end

  def invalid_id id
    if !User.exists?(id)
      display_message :notice, id, "Whoops, thats not a valid user!"
    end
  end

  def not_owner id
    if session[:user_id] != id
      display_message :warning, id, "Hey, you cant change someone else's account!"
     end
  end

  def not_friend_or_user user, id
    if !user.valid_friend?(id) and user.id != id.to_i
      display_message :warning, id, "Sorry, you must be somones friend to see their profile or torrents!"
    end
  end

  def display_message type, user_id, message
    case type
      when :notice
        logger.error("Attempt to access invalid user #{user_id} by user #{session[:user_id]}" )
      when :warning
        logger.error("Attempt to modify another users information on #{user_id} by user #{session[:user_id]}" )
      else
        logger.error("Attempt to do something bad to user #{user_id} by user #{session[:user_id]}" )
    end
    flash[type] = message
    redirect_to :action => :index
  end
end
