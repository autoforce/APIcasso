Apicasso::Engine.routes.draw do
  scope module: :apicasso do
    # When your application needs some kind of custom interaction that is not covered by
    # APIcasso's CRUD approach, you can make your own actions using our base classes and
    # objects to go straight into your logic. If you have built the APIcasso's engine into
    # a route it is important that your custom action takes precedence over the gem's ones.
    # Usage:
    # match '/:resource/:id/custom-action' => 'custom#not_a_crud', via: :get
    # mount Apicasso::Engine, at: "/api/v1"
    resources :apidocs, only: [:index]

    match '/ql/', to: 'batch#ql', via: :post
    match '/batch_create/', to: 'batch#batch_create', via: :post
    match '/batch_update/', to: 'batch#batch_update', via: :patch

    get '/:resource/', to: 'crud#index', via: :get
    match '/:resource/', to: 'crud#create', via: :post
    get '/:resource/:id', to: 'crud#show', via: :get
    match '/:resource/:id', to: 'crud#update', via: :patch
    match '/:resource/:id', to: 'crud#destroy', via: :delete
    match '/:resource/:id/:nested/', to: 'crud#nested_index', via: :get
    match '/:resource/', to: 'crud#schema', via: :options
    match '/:resource/:id', to: 'crud#schema', via: :options
    match '/:resource/:id/:nested/', to: 'crud#schema', via: :options
  end
end
