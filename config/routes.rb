Rails.application.routes.draw do
  # Add your extension routes here
  resources:line_items
  resources :countries do
      resources :states
    end
     match '/checkout' => 'checkout#edit', :state => 'one_page', :as => :checkout
       resources :users , :except => [:new,:edit]
   end
   
