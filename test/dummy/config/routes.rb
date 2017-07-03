Rails.application.routes.draw do

  mount ClarkKent::Engine => "/reports", as: 'clark_kent'

  resources :orders, only: [:show]
end
