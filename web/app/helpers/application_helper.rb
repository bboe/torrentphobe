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
end
