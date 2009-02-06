class Admin::UsersController < ApplicationController
  layout "admin"
  before_filter :is_admin?

  active_scaffold :user do |config|
    config.columns.add :fb_id
    config.list.columns.exclude [:id,
                                 :created_at,
                                 :updated_at
                                ]
  end
end
