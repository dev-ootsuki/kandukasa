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
        delete ":schema_id/bulk_truncate", to: "schemas#bulk_truncate"
        delete ":schema_id/bulk_drop", to: "schemas#bulk_drop"
  end
      resource :tables, path: ":schema_id", only:[:show, :update, :create, :destroy] do
        member do
          get ":table_id", to: "tables#get"
          post ":table_id/query", to: "tables#query"
          post ":table_id/create_data", to:"tables#create_data"
          put ":table_id/update_data", to:"tables#update_data"
          patch ":table_id/update_data", to:"tables#update_data"
          delete ":table_id/bulk_record_delete", to:"tables#bulk_record_delete"
          delete ":table_id/delete_pkey", to:"tables#delete_pkey"
        end
        resource :column, path:":table_id", only:[] do
          member do
            post "", to:"columns#create"
            patch ":column_id", to:"columns#update"
            put ":column_id", to:"columns#update"
            delete ":column_id", to:"columns#destroy"
          end
        end
      end
    end
  end
  resource :settings, only:[] do
    resource :design do
      member do
        get "", to: "designs#get"
      end
    end

    resource :authority do
      member do
        get "", to: "authorities#get"
      end
    end

    resource :configuration, only:[:show, :update] do
    end

    resource :user do
      member do
        get "", to: "users#get"
      end
    end

    resource :watch_point do
      member do
        get "", to:"watch_points#get"
      end
    end

    resource :dashboard do
      member do
        get "", to:"dashboards#get"
      end
    end

    resource :query do
      member do
        get "", to:"queries#get"
      end
    end

    resource :external_service do
      member do
        get "", to:"external_services#get"
      end
    end
  end

  resource :auth, only:[] do
    get "/login", to: "auth#login"
    get "/sso", to: "auth#sso"
    get "/logout", to: "auth#logout"
    get "/init", to: "auth#init"
  end
  
  resource :home, only:[:show] do
    
  end
end