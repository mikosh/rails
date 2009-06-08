ActionController::Routing::Routes.draw do |map|
  
  map.resources :comments, :member => {:reply => :get}
  map.resources :friends, :walls, :profiles
  map.resources :maps, :collection => {:search => :post, :addMarkers => :post, :route => :post}
  map.resources :locations, :collection => {:find => :post}
  map.resources :sent, :collection => {:delete_messages => :delete}
  map.resources :mailbox, :collection => {:delete_messages => :delete}
  #map.resources :users, :collection => {:search => :get}
  map.resources :messages, :member => { :reply => :get, :forward => :get }
  map.resources :users do |user|
    user.resources :friends
  end
  map.resources :users do |user|
    user.resources :albums do |album|
      album.resources :photos
    end
  end 
  
  map.namespace :admin do |admin|
    admin.resources :users, :member => { :suspend   => :post,
                                       :unsuspend => :post,
                                       :purge     => :delete }
    admin.resource :settings, :collection => {:calculate => :any}
  end
  
  map.root :controller => "users"
  map.search '/search', :controller => "search", :action => "index"
  map.inbox '/inbox', :controller => "mailbox", :action => "index"
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.reset  '/reset/:reset_code', :controller => 'users', :action => 'reset'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.change '/change', :controller => 'users', :action => 'change'
  
  map.resource :session
  map.active '/active', :controller => 'sessions', :action => 'active'
  map.timeout '/timeout', :controller => 'sessions', :action => 'timeout'


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
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  #map.connect '*url', :controller => 'store', :action => 'some_missing_action' 
end
