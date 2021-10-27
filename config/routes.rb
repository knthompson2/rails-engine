Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get "revenue/items", to: "revenue/items#items_by_revenue"
      get "/revenue/merchants", to: "merchants#revenue"
      get "/revenue/merchants/:id", to: "merchants#one_revenue"
      get "/merchants/most_items", to: "merchants#most_items"
      get "/merchants/find", to: "merchants#find"
      get "/items/find_all", to: "items#find_all"
      resources :merchants, only: [:index, :show] do
        get "/items", to: "merchants/items#index"
      end
      resources :items do
        get "/merchant", to: "items/merchant#show"
      end
    end
  end
end
