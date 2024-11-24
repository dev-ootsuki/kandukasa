Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resource :db_connection do
    member do
      get ":con_id", to: "db_connections#get"
      put ":con_id", to: "db_connections#update"
      patch ":con_id", to: "db_connections#update"
      delete ":con_id", to:"db_connections#destroy"
    end

    resource :schemas, path: ":con_id", only:[] do
      member do
        get ":schema_id", to: "schemas#get"
        post ":schema_id/query", to: "schemas#query"
    end
      resource :tables, path: ":schema_id", only:[:show] do
        member do
          get ":table_id", to: "tables#get"
        end
        resource :column, path:":table_id", only:[:show] do
          get ":column_id", to: "column#get"
        end
      end
    end
  end
end
