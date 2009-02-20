class LandingController < ApplicationController
  layout "landing"
  before_filter :set_facebook_session
  helper_method :facebook_session

  def index
    if facebook_session
      begin
        facebook_session.user.name
        @user = User.find_by_fb_id(facebook_session.user.id)
      rescue Facebooker::Session::SessionExpired
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def error_404
    flash[:notice] = 'Seems that the page you were looking for does not exist, so you\'ve been redirected here.'
    redirect_to :action => 'index', :status => "404 Not Found"
    respond_to do |format|
      format.html
    end
  end

  def about
    respond_to do |format|
      format.html # about.html.erb
    end
  end
end
