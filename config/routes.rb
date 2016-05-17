Rails.application.routes.draw do
  resources :donations, only: [:create, :new]
  root 'donations#new'
end
