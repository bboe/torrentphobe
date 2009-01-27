class LandingController < ApplicationController
  before_filter :set_facebook_session
  helper_method :facebook_session

  def index
    if facebook_session
      begin
        facebook_session.user.name
        @user = User.find_by_fb_id(facebook_session.user.id)
        redirect_to :controller => 'users', :action => 'show', :id => @user.id
        return
      rescue Facebooker::Session::SessionExpired
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def about
    respond_to do |format|
      format.html # about.html.erb
    end
  end
end
