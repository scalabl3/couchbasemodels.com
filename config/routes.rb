CouchbaseModels::Application.routes.draw do
  
  controller :api do
    get "/api/pull_comments" => :pull_comments
    post "/api/submit_comment" => :submit_comment
  end
  
  controller :cb_strategies do
    get "/strategies" => :index
    get "/strategies/simple" => :simple
    get "/strategies/complex" => :complex
    get "/strategies/organic" => :organic
    get "/strategies/behavioral" => :behavioral    
  end
  
  controller :cb_models do
    get '/models' => :index
    get '/models/product_catalog' => :product_catalog
    get '/models/activity_stream' => :activity_stream
  end
  
  controller :cb_patterns do
    get '/patterns' => :index
    get '/patterns/counter_id' => :counter_id
    get '/patterns/lookup' => :lookup
  end
  
  controller :user do    
    post '/comment' => :make_comment
    get  '/comments' => :retrieve_comments
    get '/logout' => :logout
    match '/auth/:provider/callback' => :authenticate
    #get "/user/authenticate" => :authenticate
  end
  
  controller :cbmodels_app do
    get '/about' => :about
    get '/couchbase' => :couchbase
  end
  
  root :to => 'cbmodels_app#index'
  
  
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
  #root :to => 'patterns#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
