# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper

  def tab_class tab_controller
    (controller.controller_name.to_sym == tab_controller) ? "main" : "bg"
  end
end
