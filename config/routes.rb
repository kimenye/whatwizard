Whatwizard::Application.routes.draw do
  post "home/wizard"
  root to: 'rails_admin/main#dashboard'
  mount RailsAdmin::Engine => '/admin'
  devise_for :users
end
