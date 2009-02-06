# Methods added to this helper will be available to all templates in the application.
require 'config/global_config.rb'
module ApplicationHelper
  include TagsHelper

  def tab_class tab_controller
    (controller.controller_name.to_sym == tab_controller) ? "main" : "bg"
  end

  def site_url
    HOST_URL 
  end

  OUR_FBIDS = [3602257, 3604035, 1018091751, 28201092, 685099174, 3603163]

  def is_admin? 
    facebook_session.user.name && OUR_FBIDS.include?(facebook_session.user.uid)
  end
  

end
