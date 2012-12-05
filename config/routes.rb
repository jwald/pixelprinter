Pixelprinter::Application.routes.draw do

  root to: 'login#index'
  match '/logout', to: 'login#logout', as: :logout

  resources :orders, only: [:index, :show] do
    member do
      get :preview
      post :print
    end
  end

  resources :print_templates, as: :templates

  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'

end

