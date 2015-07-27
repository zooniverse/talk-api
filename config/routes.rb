require 'sidekiq/web'

Rails.application.routes.draw do
  defaults format: 'json' do
    resources :announcements
    resources :boards
    resources :collections
    resources :comments do
      member do
        put :upvote
        put :remove_upvote
      end
    end
    resources :conversations
    resources :data_requests
    resources :discussions
    resources :messages
    resources :moderations
    resources :notifications
    resources :roles
    resources :subjects
    resources :subscription_preferences
    resources :subscriptions
    resources :tags do
      collection do
        get :popular
      end
    end
    resources :user_ip_bans
    resources :users
    
    root 'application#root', defaults: { format: 'html' }
  end
  
  get '/searches' => 'searches#index'
  mount Sidekiq::Web => '/sidekiq'
  match "*path", to: "application#sinkhole", via: :all
end
