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
    @user = User.find(params[:id])
    @friends = facebook_session.user.friends
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def login
    @user = User.find_or_initialize_by_fb_id( facebook_session.user.uid  )

    friend_ids = facebook_session.user.friends.map { |user| user.uid }
    friend_hash = Digest::MD5.hexdigest( friend_ids.to_s )

    name = facebook_session.user.first_name + " " + facebook_session.user.last_name

    if @user.friend_hash != friend_hash or @user.name != name
      @user.update_info(friend_ids, name)
    end

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = 'User successfully logged in.'
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
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])

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
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def files
    @user = User.find(params[:id])
    @torrents = @user.torrents
    respond_to do |format|
      format.html # files.html.erb
      format.xml
    end
  end
end
