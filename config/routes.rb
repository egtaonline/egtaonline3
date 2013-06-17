Egtaonline3::Application.routes.draw do

  resources :simulators, :games do
    resources :roles, only: [:create, :destroy] do
      resources :strategies, only: [:create, :destroy]
    end
  end

  resources :schedulers, only: [:index, :destroy] do
    collection do
      post :update_configuration
    end
    member do
      post :create_game_to_match
    end
    resources :roles, only: [:create, :destroy] do
      resources :strategies, only: [:create, :destroy]
    end
  end

  resources :generic_schedulers do
    collection do
      post :update_configuration
    end
  end

  resources :game_schedulers, :hierarchical_schedulers, :dpr_schedulers do
    collection do
      post :update_configuration
    end
  end

  resources :deviation_schedulers, :hierarchical_deviation_schedulers, :dpr_deviation_schedulers do
    collection do
      post :update_configuration
    end
  end

  resources :profile, only: :show
  resources :simulations, only: [:index, :show]

  devise_for :users

  resources :connection, only: [:new, :create]
  root to: 'high_voltage/pages#show', id: 'home'
end
