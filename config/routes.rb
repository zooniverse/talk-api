Rails.application.routes.draw do
  defaults format: 'json' do
    resources :boards
    resources :comments
    resources :conversations
    resources :discussions
    resources :focuses
    resources :messages
    resources :moderations
    resources :tags
    resources :users
    
    root 'application#root'
  end
  
  match "*path", to: "application#sinkhole", via: :all
end
