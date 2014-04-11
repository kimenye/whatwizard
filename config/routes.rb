Whatwizard::Application.routes.draw do
  get "football/wizard"
  post "home/wizard"
  root to: 'rails_admin/main#dashboard'
  mount RailsAdmin::Engine => '/admin'
  devise_for :users
end
