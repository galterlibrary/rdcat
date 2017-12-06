Rails.application.routes.draw do
  resources :categories
  devise_for :users
  
  resources :organizations
  resources :datasets do 
    member do 
      post 'mint_doi'
    end

    collection do
      post 'search'
    end

    resources :distributions do
      member do 
        get 'download'
      end
    end
  end
  resources :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'welcome/index' => 'welcome#index'
  post 'user_lookup/ldap' => 'user_lookup#ldap'

  get 'fast_subjects/suggestions' => 'fast_subjects#suggestions'
end
