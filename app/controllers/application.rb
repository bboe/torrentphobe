# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery  :secret => 'abb88c99ec7c1b2421736c49e2ea3a9d'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  OUR_FBIDS = [3602257, 3604035, 1018091751, 28201092, 685099174, 3603163]

  def is_admin?
    begin
      unless facebook_session && facebook_session.user && facebook_session.user.name && OUR_FBIDS.include?(facebook_session.user.uid)
        redirect_to "/"
      end
    rescue
      redirect_to "/"
    end
  end

  # This is a somewhat hacky way to verify that the user's facebook session
  # is valid.
  def user_logged_in?
    if facebook_session
      begin
        facebook_session.user.name
        return true
      rescue Facebooker::Session::SessionExpired
        redirect_to "/"
      end
    end
    redirect_to "/"
  end

  def get_current_user
    current_user ||= nil
    return current_user if !current_user.nil?
    current_user = User.find(session[:user_id])
  end

  def login_required
    return true if session[:user_id] and User.exists?(session[:user_id])
    #Dont enforce login when in development mode so we can still develop locally
    return true if ENV["RAILS_ENV"] == "development"
    deny_access
    return false
  end

  def deny_access
    flash[:error] = 'Hey, you need to login to view this page'
    redirect_to :controller => :landing, :action => :index
  end  

  def handle_sort params
    sort_by = ( params[:c].nil? ? 'name' : params[:c] )
    sort_direction = ((params[:d] == "up") ? "ASC" : "DESC")

    case sort_by
      when "category_id","size"
        ordering = [sort_by,sort_direction].join(" ")
      else
        ordering = [:name,sort_direction].join(" ")
    end
    return ordering
  end

  def get_host_url
      if request.env["HTTP_X_FORWARDED_HOST"]
      host_url = request.env["HTTP_X_FORWARDED_HOST"]
    else
      host_url = request.env["HTTP_HOST"]
    end

    unless host_url[0..7] == "http://"
      host_url = "http://" + host_url
    end
  end
end
