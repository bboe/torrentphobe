class Admin::TorrentsController < ApplicationController
  layout "admin"
  active_scaffold :torrent do |config|
    config.list.columns.exclude [:data,
                                 :id,
                                 :created_at,
                                 :updated_at
                                ]
                    
  end
end
