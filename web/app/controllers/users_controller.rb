class UsersController < ApplicationController
  layout "main"

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
    @user = User.find_or_create_by_fb_id(facebook_session.user.uid)
    user_ids = []
    friend_ids = []
    User.find(:all).each {|user| user_ids << user.fb_id}
    facebook_session.user.friends.each {|user| friend_ids << user.uid}
    friends = user_ids & friend_ids
    friends.each do |friend|
      f_id = User.find_by_fb_id(friend)
      Relationship.create({:user_id => @user.id, :friend_id => f_id})
      Relationship.create({:user_id => f_id, :friend_id => @user.id})
    end

    redirect_to(@user)
  end

  def logout
    reset_session
    facebook_session = nil
    redirect_to(:action => :index)
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
    throw @user
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
end
