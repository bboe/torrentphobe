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

  def display_flash_messages
    [:notice, :warning, :message].map { |f| content_tag(:div, flash[f], :class => f, :id => "flash-message") if flash[f] }
  end

  def sort_link(title, column, options = {})
    sort_dir = params[:d] == 'up' ? 'down' : 'up'
    link_to( title, request.parameters.merge( {:c => column, :d => sort_dir} ) ) + " " +
    link_to( image_tag("sort_arrow_"+sort_dir+".png"), request.parameters.merge( {:c => column, :d => sort_dir} ) )
  end
end
