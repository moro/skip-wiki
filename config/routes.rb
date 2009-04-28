ActionController::Routing::Routes.draw do |map|
  map.root :controller=>"notes", :action=>"dashboard"

  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'accounts', :action => 'create'
  map.signup   '/signup',   :controller => 'accounts', :action => 'new'

  map.resources :oauth_clients
  map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
  map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
  map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
  map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'

  map.resources :accounts

  map.resources :users do |users|
    users.resources :memberships, :collection=>{:skip=>:post}
  end

  map.resources :groups do |group|
    group.resources :memberships
  end

  map.resources :notes do |note|
    note.resources :label_indices
    note.resources :pages, :member => {:recovery => :post}, :new => {:preview => :post} do |page|
      page.resources :histories, :collection=>{:diff=>:get}
    end
    note.resources :attachments
  end
  map.resources :pages

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :conditions => {:method => :get },
                                                                                  :requirements=>{:open_id_complete=>/\d+/}
  map.resource :session

  map.namespace 'admin' do |admin_map|
    admin_map.root :controller=>'users', :action=>'index'
    admin_map.resources :users

    admin_map.resources :notes do |note|
      note.resources :pages, :new => {:preview => :post} do |page|
        page.resources :histories, :collection=>{:diff=>:get}
        page.resources :attachments
      end
      note.resources :attachments
    end

    admin_map.resources :groups do |group|
      group.resources :memberships
    end

    admin_map.resources :accounts
  end

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
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
