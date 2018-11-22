Apicasso.configure do |config|
  config.origins = '*'
  config.headers = :any
  config.resource = '*'
  config.credentials = '*'
  config.max_age = 1728000
  config.methods = [:get, :post, :delete, :put, :patch, :options]
  config.vary = nil
  config.expose = nil
  config.if = nil
end
