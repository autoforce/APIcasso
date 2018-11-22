# frozen_string_literal: true

module Apicasso
  # Behavior control for the Apicasso::Engine
  class Engine < ::Rails::Engine
    require 'rack/cors'
    config.middleware.use Rack::Cors do
      allow do
        origins Apicasso.configuration.origins
        resource Apicasso.configuration.resource,
          headers: Apicasso.configuration.headers,
          methods: Apicasso.configuration.methods,
          credentials: Apicasso.configuration.credentials,
          max_age: Apicasso.configuration.max_age,
          if: Apicasso.configuration.if,
          vary:  Apicasso.configuration.vary,
          expose: Apicasso.configuration.expose
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
