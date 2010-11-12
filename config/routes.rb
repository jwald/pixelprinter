ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'

  map.resources :orders, :only => [:index, :show], :member => {:preview => :get, :print => :post} do |orders|
    orders.resources :print_templates, :only => [:show]
  end  
  
  map.resources :print_templates, :as => 'templates'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
