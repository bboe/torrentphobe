class Admin::SwarmsController < ApplicationController
  layout "admin"
  before_filter :is_admin?
  active_scaffold :swarm do |config|
    config.list.columns.exclude [:id,
                                 :created_at,
                                 :updated_at
                                ]
  end
end
