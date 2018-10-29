Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  scope(as: "app", path: "/:tenant") do
    get "/", to: "customers#index"

    resources :customer_imports, only: [:new, :create, :show] do
      post :finalize, on: :member
      post :cancel, on: :member
    end

    resources :customer_import_rows, only: [:update, :destroy]
  end
end
