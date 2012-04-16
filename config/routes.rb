Rails.application.routes.draw do
  # Add your extension routes here
  resources:line_items
  resources :countries do
      resources :states
    end
end
