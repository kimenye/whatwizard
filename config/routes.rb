require "sidekiq/web"

Whatwizard::Application.routes.draw do
  post "football/wizard"
  post "home/wizard"
  post "voting/wizard"
  get "voting/results"
  # post "home/wizard_new"
  root to: 'rails_admin/main#dashboard'
  mount RailsAdmin::Engine => '/admin'
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users
end
