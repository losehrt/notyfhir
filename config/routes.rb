Notyfhir::Engine.routes.draw do
  resources :notifications, only: [:index, :show] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end
  
  resources :notification_settings, only: [:index] do
    collection do
      post :test
    end
  end
  
  resources :push_subscriptions, only: [:create, :destroy]
end