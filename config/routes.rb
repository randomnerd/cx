Cx::Application.routes.draw do
  require 'resque/server'
  require 'resque_scheduler'
  require 'resque_scheduler/server'
  mount Resque::Server => "/hq/resque"
  devise_for :users, skip: :all
  devise_scope :user do
    match '/users/sign_out', to: 'sessions#destroy', via: [:delete]
    post '/users/sign_in', to: 'sessions#create'
    post '/users', to: 'devise/registrations#create'
  end
  post '/pusher/auth', to: 'pusher#auth'
  root 'chat#index'
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :currencies, only: [:index, :show]
      resources :balances, only: [:index]
      resources :balance_changes, only: [:index]
      resources :address_book_items, only: [:index, :create, :update, :destroy]
      resources :notifications, only: [:index, :update, :destroy] do
        collection do
          post :ack_all
          post :del_all
        end
      end
      resources :messages, only: [:create, :update, :destroy, :index]
      resources :trade_pairs, only: [:create, :update, :destroy, :index] do
        resources :chart_items, only: [:index]
      end
      resources :trades, only: [:index]
      resources :orders, only: [:create, :update, :destroy, :index] do
        post :cancel, to: 'orders#cancel'
      end
      resources :trades, only: [:create, :update, :destroy, :index]
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
