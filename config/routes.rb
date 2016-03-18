Rails.application.routes.draw do
  resources :donations, only: [:create, :new]
  root :to => "donations#new"
end
