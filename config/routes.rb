Egtaonline3::Application.routes.draw do
  resources :users, only: [:index, :update]
  devise_for :users, controllers: { registrations: 'registrations' }
  
  namespace :api do
    namespace :v3 do
     
      resources :generic_schedulers, except: %w(new edit) do
        member do
          post :add_profile, :remove_profile, :add_role, :remove_role
        end
      end
      resources :simulators, :games, only: [:show, :index] do
        member do
          post :add_strategy, :remove_strategy, :add_role, :remove_role
        end
      end
      resources :profiles, only: :show
      resources :schedulers, only: :show
    end
  end

  resources :simulators do
    resources :roles, only: [:create, :destroy] do
      member do
        post :add_strategy
        post :remove_strategy
      end
    end
  end

  resources :games do
    post :create_process, on: :member
    post :create_learning_process, on: :member
    post :analyze, on: :member
    resources :roles, only: [:create, :destroy] do
      member do
        post :add_strategy
        post :remove_strategy

      end
    end
    resources :control_variables, only: [:edit, :update]
    collection do
      post :update_configuration
    end
    resources :analyses, only: [:index]
  end

  resources :schedulers, except: :show do
    collection do
      post :update_configuration
    end
    member do
      post :create_game_to_match
    end
    resources :roles, only: [:create, :destroy] do
      member do
        post :add_strategy
        post :remove_strategy
        post :add_deviating_strategy
        post :remove_deviating_strategy
      end
    end
  end

  resources :game_schedulers, :hierarchical_schedulers, :dpr_schedulers,
            :generic_schedulers, :hierarchical_deviation_schedulers,
            :dpr_deviation_schedulers, :deviation_schedulers, except: :delete

  resources :profiles, only: :show
  resources :simulations, only: [:index, :show]
  resources :analyses, only: [:index, :show]

  resources :connection, only: [:new, :create]
  root to: 'high_voltage/pages#show', id: 'home'

  require 'sidekiq/web'
  authenticate :user do
    mount Sidekiq::Web, at: '/background_workers'
  end
end
