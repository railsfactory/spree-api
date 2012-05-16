Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources:line_items
  match '/t/*id', :to => 'search#search'
   match '/detailed_list', :to => 'products#detailed_list', :via => :get
   match '/detailed_show/:id', :to => 'products#detailed_show', :via => :get
  resources :countries do
      resources :states
    end
    match '/checkout' => 'checkout#edit', :state => 'one_page', :as => :checkout
      #resources :users , :except => [:new,:edit]
       devise_scope :user do
    match '/users' => 'user_registrations#create',:via=>:post
    match '/user/log_in'=>'log#create',:via=>:post
  end
  resources :inventory_units, :except => [:new,:edit] do
      put :event, :on => :member
    end
 namespace :admin do
  resources:variants
  resources:taxons
  resources:product_properties
  match '/reports/best_selling_products', :to => 'reports#best_selling_products', :via => :get
match '/reports/gross_selling_products', :to => 'reports#gross_selling_products', :via => :get
match '/reports/top_spenders', :to => 'reports#top_spenders', :via => :get
match '/reports/recent_orders', :to => 'reports#recent_orders', :via => :get
match '/reports/out_of_stock', :to => 'reports#out_of_stock', :via => :get
match '/reports/day_order_count', :to => 'reports#day_order_count', :via => :get
match '/reports/day_order_value', :to => 'reports#day_order_value', :via => :get
match '/reports/month_order_value', :to => 'reports#month_order_value', :via => :get
match '/reports/month_order_count', :to => 'reports#month_order_count', :via => :get
end
 #match '/*path' => 'content#show'
end
