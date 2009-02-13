class Admin::TorrentsController < ApplicationController
  layout "admin"
  before_filter :set_facebook_session
  helper_method :facebook_session
  before_filter :is_admin?

  active_scaffold :torrent do |config|
    config.list.columns.exclude [:data,
                                 :id,
                                 :created_at,
                                 :updated_at
                                ]
                    
  end
end
