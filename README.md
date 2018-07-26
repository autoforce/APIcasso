<img src="https://raw.githubusercontent.com/ErvalhouS/APIcasso/master/APIcasso.png" width="300" /> [![Gem Version](https://badge.fury.io/rb/apicasso.svg)](https://badge.fury.io/rb/apicasso) [![Docs Coverage](https://inch-ci.org/github/autoforce/APIcasso.svg?branch=master)](https://inch-ci.org/github/autoforce/APIcasso.svg?branch=master) [![Maintainability](https://api.codeclimate.com/v1/badges/b58bbd6b9a0376f7cfc8/maintainability)](https://codeclimate.com/github/autoforce/APIcasso/maintainability) [![codecov](https://codecov.io/gh/autoforce/APIcasso/branch/master/graph/badge.svg)](https://codecov.io/gh/autoforce/APIcasso) [![Build Status](https://travis-ci.org/autoforce/APIcasso.svg?branch=master)](https://travis-ci.org/autoforce/APIcasso)

JSON API development can get boring and time consuming. If you think it through, every time you make one you use almost the same route structure, pointing to the same controller actions, with the same ordering, filtering and pagination features.

**APIcasso** is intended to be used as a full-fledged CRUD JSON API or as a base controller to speed-up development.
It is a route-based resource abstraction using API key scoping. This makes it possible to make CRUD-only applications just by creating functional Rails' models. It is a perfect candidate for legacy Rails projects that do not have an API. Access to your application's resources is managed by a `.scope` JSON object per API key. It uses that permission scope to restrict and extend access.

## Installation
Add this line to your application's `Gemfile`:

```ruby
gem 'apicasso'
```

And then execute this to generate the required migrations:
```bash
$ rails g apicasso:install
```
You will need to use a database with JSON fields support to use this gem.

## Usage
After installing APIcasso into your application you can mount a full-fledged CRUD JSON API just by attaching into some route. Usually you will have it under a scoped route like `/api/v1` or a subdomain. You can do that by adding this into your `config/routes.rb`:
```ruby
  # To mount your APIcasso routes under the path scope `/api/v1`
  mount Apicasso::Engine, at: "/api/v1"
  # or, if you prefer subdomain scope isolation
  constraints subdomain: 'apiv1' do
    mount Apicasso::Engine, at: "/"
  end
```
Your API will reflect very similarly a `resources :resource` statement with the following routes:
```ruby
  get '/:resource/' # Index action, listing a `:resource` collection from your application
  post '/:resource/' # Create action for one `:resource` from your application
  get '/:resource/:id' # Show action for one `:resource` from your application
  patch '/:resource/:id' # Update action for one `:resource` from your application
  delete '/:resource/:id' # Destroy action for one `:resource` from your application
  get '/:resource/:id/:nested/' # Index action, listing a collection of a `:nested` relation from one of your application's `:resource`
  options '/:resource/' # A schema dump for the required `:resource`
  options '/:resource/:id/:nested/' # A schema dump for the required `:nested` relation from one of your application's `:resource`
```
This means all your application's models will be exposed as `:resource` and it's relations will be exposed as `:nested`. It will enable you to CRUD and get schema metadata from your records.

 > But this is permissive as hell! I do not want to expose my entire application like this, haven't you thought about security?

*Sure!* The API is being exposed using authentication through `Authorization: Token` [HTTP header authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01). The API key objects are manageable through the `Apicasso::Key` model, which gets setup at install. When a new key is created a `.token` is generated using an [Universally Unique Identifier(RFC 4122)](https://tools.ietf.org/html/rfc4122).

Your API is then exposed based on each `Apicasso::Key.scope` definition
```ruby
  Apicasso::Key.create(scope:
                        { manage:
                            [{ order: true }, { user: { account_id: 1 } }],
                          read:
                            [{ account: { id: 1 } }]
                        })
```
This translates directly into which parts of your application is exposed to each APIcasso keys.

The key from this example will have full access to all orders and to users with `account_id == 1`. It will have also read-only access to accounts with `id == 1`.

This saves you the trouble of having to setup each and every controller for each model. And even if your application really need it, just make your controllers inherit from `Apicasso::CrudController` and extend it's functionalities. This authorization feature is why one of the dependencies for this gem is [CanCanCan](https://github.com/CanCanCommunity/cancancan), that abstracts the scope field into authorization for your application's resources.

The `crud#index` and `crud#nested_index` actions are already equipped with pagination, ordering and filtering.

 - You can pass `params[:sort]` with field names preffixed with `+` or `-` to configure custom ordering per request. I.E.: `?sort=+updated_at,-name`
 - You can pass `params[:q]` using [ransack's search matchers](https://github.com/activerecord-hackery/ransack#search-matchers) to build a search query. I.E.: `?q[full_name_start]=Picasso`
 - You can pass `params[:page]` and `params[:per_page]` to build pagination options. I.E.: `?page=2&per_page=12`

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ErvalhouS/APIcasso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code of conduct](http://contributor-covenant.org/).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of conduct
Everyone interacting in the APIcasso project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ErvalhouS/APIcasso/blob/master/CODE_OF_CONDUCT.md).

## TODO

 - Add gem options like: Token rotation, Alternative authentication methods
 - Response fields selecting
 - Rate limiting
 - Testing suite
 - Travis CI
