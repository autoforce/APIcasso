Rails.application.routes.draw do
  mount Apicasso::Engine, at: '/api/v1'
end
