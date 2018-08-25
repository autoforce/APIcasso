Apicasso::Engine.routes.draw do
  scope module: :apicasso do
    resources :apidocs, only: [:index]
    get '/:resource/', to: 'crud#index', via: :get
    match '/:resource/', to: 'crud#create', via: :post
    get '/:resource/:id', to: 'crud#show', via: :get
    match '/:resource/:id', to: 'crud#update', via: :patch
    match '/:resource/:id', to: 'crud#destroy', via: :delete
    match '/:resource/:id/:nested/', to: 'crud#nested_index', via: :get
    match '/:resource/', to: 'crud#schema', via: :options
    match '/:resource/:id/:nested/', to: 'crud#schema', via: :options
  end
end
