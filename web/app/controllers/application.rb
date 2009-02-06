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
    unless facebook_session && facebook_session.user && facebook_session.user.name && OUR_FBIDS.include?(facebook_session.user.uid)
      redirect_to "/"
    end
  end
end
