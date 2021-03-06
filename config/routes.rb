Webapp::Application.routes.draw do
  get "users/new"

  resources :quotes
  resources :users
  resources :categories
  resources :user_sessions

  match '/fblogin' => 'user_session#login_facebook'
  match '/login/facebook/callback' => 'user_session#login_facebook_callback'
  match '/posttofb' => 'user_session#post_to_facebook'
  match '/fblogout' => 'user_session#logout_facebook'

  match '/twitterlogin' => 'user_session#login_twitter'
  match '/login_twitter_callback' => 'user_session#login_twitter_callback'
  match '/posttotwitter' => 'user_session#post_to_twitter'
  match  '/login' => 'user_session#new'
  match '/register' => 'users#new'
  match '/logout' => 'user_session#destroy'

  match '/user_sessions/create' => 'user_session#create'
  match '/authors' => 'quotes#authors'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'quotes#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
