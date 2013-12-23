require 'sidekiq/web'

Cx::Application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      resources :currencies, only: [:index, :show] do
        member do
          post :generate_address
          post :withdraw
        end
      end
      resources :users, only: [:update] do
        member do
          post :verify_totp
          get :tfa_key
          post :set_nickname
        end
      end
      resources :blocks, only: [:index, :show]
      resources :block_payouts, only: [:index]
      resources :hashrates, only: [:index]
      resources :workers, only: [:index, :create, :update, :destroy]
      resources :worker_stats, only: [:index]
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
    registrations: 'registrations',
    passwords: 'passwords'
  }

  namespace :hq do
    authenticate :user, -> u { u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
    root to: 'users#index'
    resources :currencies, only: [:index, :new, :create, :update, :edit] do
      member do
        get :disable
        get :enable
      end
    end
    resources :trade_pairs, only: [:index, :new, :create, :update, :edit] do
      member do
        get :disable
        get :enable
      end
    end
    resources :users, only: [:index, :new, :create, :update, :edit] do
      member do
        get :ban
        get :unban
        get :masq, to: 'masquerades#create'
      end
      collection { get :unmasq, to: 'masquerades#destroy' }
    end
  end

  post '/pusher/auth', to: 'pusher#auth'
  root to: 'home#index'
  get '*path', to: 'home#index'

  # fake routes for url helpers
  get '/account/change_password/:token', to: 'home#index', as: :change_password
end
