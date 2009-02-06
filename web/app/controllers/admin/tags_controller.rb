class Admin::TagsController < ApplicationController
  layout "admin"
  before_filter :set_facebook_session
  helper_method :facebook_session
  before_filter :is_admin?

  active_scaffold :tag
end
