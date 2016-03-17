Rails.application.routes.draw do
  resources :donations, only: [:create, :new]
end
