Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dashboard
  root to: "dashboard#index"

  # Admin managing Schools
  resources :schools

  # SchoolAdmin managing Courses and Batches
  resources :courses do
    resources :batches, shallow: true do
      # Custom route for students to request enrollment
      post "enroll", on: :member
    end
  end

  # Managing Enrollments (Approvals/Denials)
  resources :enrollments, only: [ :index, :update ] do
    member do
      patch :approve
      patch :deny
    end
  end

  resources :users
end
