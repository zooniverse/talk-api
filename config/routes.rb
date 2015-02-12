Rails.application.routes.draw do
  defaults format: 'json' do
    resources :boards
    resources :comments do
      member do
        put :upvote
        put :remove_upvote
      end
    end
    resources :conversations
    resources :discussions
    resources :focuses
    resources :messages
    resources :moderations
    resources :tags do
      collection do
        get :popular
      end
    end
    resources :users
    
    root 'application#root'
  end
  
  match "*path", to: "application#sinkhole", via: :all
end
