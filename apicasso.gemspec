$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'apicasso/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'apicasso'
  s.version       = Apicasso::VERSION
  s.authors       = ['Fernando Bellincanta']
  s.email         = ['ervalhous@hotmail.com']
  s.homepage      = 'https://github.com/ErvalhouS/APIcasso'
  s.summary       = 'An abstract API design as a mountable engine'
  s.description   = "JSON API development can get boring and time consuming. If you think it through, every time you make one you use almost the same route structure pointing the same controller actions, with the same features: ordering, filtering and pagination. APIcasso is intended to be used as a full-fledged CRUD JSON API or as a base controller. It makes development and easier job by abstracting route-based resource operations into API key scoping. This makes it possible to make CRUD-only applications just by creating functional Rails' models. The magic is done by a `.scope` JSON object which exists in every API key. It uses permission scopes as keys to restrict and extend APIcasso access to your application's resources."
  s.license       = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.md']
  s.require_path = 'lib'
  s.test_files = Dir["spec/**/*"]


  s.add_development_dependency 'bundler'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

  s.add_dependency 'cancancan', '~> 2.0'
  s.add_dependency 'rails', '> 5'
  s.add_dependency 'swagger-blocks'
  s.add_dependency 'ransack'
  s.add_dependency 'will_paginate', '~> 3.1.0'
end
