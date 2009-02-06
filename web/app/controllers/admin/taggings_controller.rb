class Admin::TaggingsController < ApplicationController
  layout "admin"
  before_filter :is_admin?
  active_scaffold :tagging do |config|
    config.list.columns.exclude [:id,
                                 :created_at,
                                 :updated_at
                                ]
  end
end
