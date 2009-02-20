ActionController::Routing::Routes.draw do |map|
  map.connect '/swarms/a/*id', :controller => 'swarms', :action => 'a'
  map.resources :swarms

  map.resources :categories

  map.connect '/torrents/search/:id', :controller => 'torrents', :action => 'search'
  map.connect '/torrents/destroy/:id', :controller => 'torrents', :action => 'destroy'
  map.connect '/torrents/download_torrent_file/:id', :controller => 'torrents', :action => 'download_torrent_file'
  #map.connect '/torrents/:action/:id', :controller => 'torrents'
  #map.connect '/torrents/:id', :controller => 'torrents', :action => 'show'
  map.resources :torrents

  map.connect '/admin/torrents/:action/:id', :controller => "admin/torrents"
  map.connect '/admin/users/:action/:id', :controller => "admin/users"
  map.connect '/admin/categories/:action/:id', :controller => "admin/categories"
  map.connect '/admin/tags/:action/:id', :controller => "admin/tags"
  map.connect '/admin/swarms/:action/:id', :controller => "admin/swarms"
  map.connect '/admin/relationships/:action/:id', :controller => "admin/relationships"
  map.connect '/admin/landing/:action/:id', :controller => "admin/landing"
  map.connect '/admin/taggings/:action/:id', :controller => "admin/taggings"

  map.resources :tags

  map.connect '/users/login', :controller => 'users', :action => 'login'
  map.connect '/users/logout', :controller => 'users', :action => 'logout'
  map.connect '/users/files/:id', :controller => 'users', :action => 'files'
  map.connect '/users/inviteFriends', :controller => 'users', :action => 'inviteFriends'
  map.connect '/users/send_invites', :controller => 'users', :action => 'send_invites'
  map.resources :users

  map.connect '/home', :controller => 'home', :action => 'index'
  map.connect '/about', :controller => 'landing', :action => 'about'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "landing", :action => 'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

   map.connect '*path', :controller => 'landing', :action => :error_404
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
