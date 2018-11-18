Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  get "/confirm/:membership_id/access", to: "customer_membership_confirmations#new", as: "confirm_customer_membership"
  post "/confirm/:membership_id/access", to: "customer_membership_confirmations#create", as: nil
  get "/confirm/:membership_id/ok", to: "customer_membership_confirmations#success", as: "customer_membership_success"
  get "/confirm/:membership_id/error", to: "customer_membership_confirmations#error", as: "customer_membership_error"

  scope(as: "app", path: "/:tenant") do
    get "/", to: "customers#index"

    resources :customer_imports, only: [:new, :create, :show] do
      post :finalize, on: :member
      post :cancel, on: :member
    end

    resources :customer_import_rows, only: [:update, :destroy]
  end
end
