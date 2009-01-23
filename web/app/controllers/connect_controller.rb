class ConnectController < ApplicationController
  layout "main"

  before_filter :set_facebook_session
  helper_method :facebook_session

  def index
    if session[:facebook_session]
      @user = session[:facebook_session].user
    else
      @user = nil
    end
  end

end
