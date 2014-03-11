Whatwizard::Application.routes.draw do
  post "home/wizard"
  mount RailsAdmin::Engine => '/admin', :as => :root
  devise_for :users
  # root :to => "/admin"
end
