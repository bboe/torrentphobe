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
    args = request.parameters.merge( {:c => column, :d => sort_dir} )
    if params[:c] == title.downcase
      link_to( title, args ) + " " + link_to( image_tag("sort_arrow_"+sort_dir+".png"), args )
    else
      link_to( title, args )
    end
  end

  def production_server?
    return false if request.env["HTTP_X_FORWARDED_HOST"].nil? and request.env["HTTP_HOST"].nil?
    if request.env["HTTP_X_FORWARDED_HOST"]
      host_url = request.env["HTTP_X_FORWARDED_HOST"]
    else
      host_url = request.env["HTTP_HOST"]
    end

    unless host_url[0..7] == "http://"
      host_url = "http://" + host_url
    end
    
    host_url == "http://torrentpho.be"
  end
end
