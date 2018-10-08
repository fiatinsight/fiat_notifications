FiatNotifications::Engine.routes.draw do
  resources :notifications do
    get :mark_all_read, on: :collection
  end
end
