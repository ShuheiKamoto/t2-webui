Raspberry::Application.routes.draw do
  
  get "account/index"

  get "repository/index"
  
  root :to => 'home#index'
  
  controller :home do
    match 'home', :to => :index
    match 'authorize', :to => :authorize
    match 'signout', :to => :signout
  end

  controller :signup do
    match 'signup', :to => :index
    match 'signupsave', :to => :save
  end

  controller :repository do
    match 'repository', :to => :index
    match 'applicationdetail', :to => :detail
    match 'applicationcreate', :to => :create
    match 'applicationcreatesave', :to => :create_save
    match 'applicationdelete', :to => :delete
    match 'applicationupload', :to => :upload
    match 'applicationuploadsave', :to => :upload_save
    match 'applicationhistory', :to => :history
    match 'modcollaboratorrole', :to => :mod_collaborator_role
    match 'delcollaborator', :to => :del_collaborator
    match 'addcollaborator', :to => :add_collaborator
    match 'modinstance', :to => :mod_instance
    match 'deploy', :to => :deploy
  end
  
  controller :account do
    match 'account', :to => :index
    match 'passchange', :to => :password_change
    match 'addaplication', :to => :add_application
    match 'deleteaplication', :to => :delete_application
    match 'updateapplicationkey', :to => :update_application_key
  end

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
