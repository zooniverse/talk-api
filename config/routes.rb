require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  defaults format: 'json' do
    resources :announcements
    resources :blocked_users
    resources :boards
    resources :comments do
      member do
        put :upvote
        put :remove_upvote
      end
    end
    resources :conversations
    resources :data_requests
    resources :discussions
    resources :mentions
    resources :messages
    resources :moderations
    resources :notifications do
      collection do
        put :read
      end
    end
    resources :projects
    resources :roles
    resources :subscription_preferences
    resources :subscriptions
    resources :suggested_tags
    resources :tags do
      collection do
        get :popular
        get :autocomplete
      end
    end
    resources :user_ip_bans
    resources :users do
      collection do
        get :autocomplete
      end
    end
    resources :votable_tags
  end

  root 'application#root'
  get '/searches' => 'searches#index'
  get '/unsubscribe' => 'unsubscribe#index'
  mount Sidekiq::Web => '/sidekiq'
  match "*path", to: "application#sinkhole", via: :all
end
