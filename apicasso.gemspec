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
  s.description   = "Create APIs in a fast and dynamic way, without the need to develop everything from scratch. You just need to create your models and let APIcasso do the rest for you. It is the perfect candidate to make your project development go faster or for legacy Rails projects that do not have an API. If you think it through, JSON API development can get boring and time consuming. Every time you use almost the same route structure, pointing to the same controller actions, with the same ordering, filtering and pagination features. APIcasso is intended to be used to speed-up development, acting as a full-fledged CRUD JSON API into all your models. It is a route-based abstraction that lets you create, read, list, update or delete any ActiveRecord object in your application. This makes it possible to make CRUD-only applications just by creating functional Rails' models. Access to your application's resources is managed by a .scope JSON object per API key. It uses that permission scope to restrict and extend access."
  s.license       = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.md']
  s.require_path = 'lib'
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'capybara', '~> 3.15.0'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'

  s.add_dependency 'cancancan', '>= 2', '< 4'
  s.add_dependency 'friendly_id', '>= 5.2', '< 5.4'
  s.add_dependency 'rack-cors'
  s.add_dependency 'rails', '> 5'
  s.add_dependency 'ransack'
  s.add_dependency 'swagger-blocks'
  s.add_dependency 'will_paginate', '~> 3.1.0'
end
