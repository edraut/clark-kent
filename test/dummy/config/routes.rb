Rails.application.routes.draw do

  mount ClarkKent::Engine => "/reports"

  resources :orders, only: [:show]
end
