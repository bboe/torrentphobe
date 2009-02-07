class UsersController < ApplicationController
  layout "main"

  require 'digest/md5'
  before_filter :set_facebook_session
  helper_method :facebook_session

  # GET /users
  # GET /users.xml
  def index      
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
       display_notice params[:id], "Whoops, thats not a valid user!"
    else
        @friends = facebook_session.user.friends
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @user }
        end
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
     begin
       @user = User.find(params[:id])
     rescue ActiveRecord::RecordNotFound
       display_notice params[:id], "Whoops, thats not a valid user!"
     end

     if session[:user_id] != @user.id
       return display_warning params[:id], "I dont think so, thats not your profile to edit!"
     end
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
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      display_notice params[:id], "Whoops, thats not a valid user!"
    end

    if session[:user_id] != @user.id
      return display_warning params[:id], "I dont think so, thats not your profile to update!"
    end

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
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      display_notice params[:id], "Whoops, thats not a valid user!"
    end

    if session[:user_id] != @user.id
      return display_warning params[:id], "Hey you cant delete other peoples profiles!"
    end

    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def files
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      display_notice params[:id], "Whoops, thats not a valid user!"
    end

    @torrents = @user.torrents
    respond_to do |format|
      format.html # files.html.erb
      format.xml
    end
  end

  def display_warning user_id, message
      logger.error("Attempt to perform modify another user #{user_id} by user #{session[:user_id]}" )
      flash[:warning] = message
      redirect_to :action => :index
  end

  def display_notice user_id, message
      logger.error("Attempt to access invalid user id #{user_id} by user #{session[:user_id]}" )
      flash[:notice] = message
      redirect_to :action => :index
  end
end
