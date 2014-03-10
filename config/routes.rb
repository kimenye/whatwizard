Whatwizard::Application.routes.draw do
  post "home/wizard"
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users
end
