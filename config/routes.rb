require 'sidekiq/web'

Cx::Application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :currencies, only: [:index, :show] do
        member do
          post :generate_address
          post :withdraw
        end
      end
      resources :deposits, only: [:index]
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

  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations'
  }

  authenticate :user, -> u { u.admin? } do
    mount Sidekiq::Web => '/hq/sidekiq'
  end
  post '/pusher/auth', to: 'pusher#auth'
  get '*path', to: 'home#index'
end
