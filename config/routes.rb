ClarkKent::Engine.routes.draw do
  resources :reports do
    member do
      get :download_link
      post :clone
    end
  end
  resources :report_filters
  resources :report_columns
  resources :report_emails
  resources :user_report_emails
  root to: 'reports#index'
end
