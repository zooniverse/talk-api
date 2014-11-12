Rails.application.routes.draw do
  defaults format: 'json' do
    root 'application#root'
  end
end
