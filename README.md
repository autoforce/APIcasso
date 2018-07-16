# APIcasso
JSON API development can get boring and time consuming. If you think it through, every time you make one you use almost the same route structure pointing the same controller actions, with the same features: ordering, filtering and pagination.
*APIcasso* is intended to be used as a full-fledged CRUD JSON API or as a base controller.

<img src="https://raw.githubusercontent.com/ErvalhouS/APIcasso/master/apicasso.jpg" width="800" />

It makes development and easier job by abstracting route-based resource operations into API key scoping. This makes it possible to make CRUD-only applications just by creating functional Rails' models. The magic is done by a `.scope` JSON object which exists in every API key. It uses permission scopes as keys to restrict and extend APIcasso access to your application's resources.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'apicasso'
```

And then execute this to generate the required migrations:
```bash
$ rails g apicasso:install
```
You need a database with JSON fields support to use this gem.

## Usage
After installing APIcasso into your application you can mount a full-fledged CRUD JSON API just by mounting it into some path. Usually you will have it under a scoped route like `/api/v1` or something to separate it from your main application.
```ruby
  mount Apicasso::Engine, at: "/api/v1"
```
With that in place you application will now expose some routes to be consumed:
```ruby
  get '/:resource/'
  post '/:resource/'
  get '/:resource/:id'
  patch '/:resource/:id'
  delete '/:resource/:id'
  get '/:resource/:id/:nested/'
  options '/:resource/'
  options '/:resource/:id/:nested/'
```
This means all your application's models will be exposed as `:resource` and it's relations will be exposed as `:nested`. It will enable you to list, show, create, update and get schema metadata from your records.

 > But this is permissive as hell! I do not want to expose my application as this, haven't you thought about security?

*Sure!* This API is exposed using `Authorization: Token` [HTTP header authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01), the object is manageable through `Apicasso::Key` objects, which gets setup at install. It's `.token` is generated on object creation using an [Universally Unique Identifier(RFC 4122)](https://tools.ietf.org/html/rfc4122). This object exposes your resources to specific APIcasso keys through it's `.scope` definition.
```ruby
  Apicasso::Key.create(scope:
                        { manage:
                            [{ order: true }, { user: { account_id: 1 } }],
                          read:
                            [{ account: { id: 1 } }]
                        })
```
Such an APIcasso key will have full access to all orders, to users with `account_id == 1` and read-only access to accounts with `id == 1`. This avoids you having to setup each and every controller for each model, but if your application really needs it just make your controller inherit from `Apicasso::CrudController` and extend it's functionalities. This feature is why one of the dependencies for this gem is [CanCanCan](https://github.com/CanCanCommunity/cancancan), which uses that scope field to authorize access into your application's resources.

The `crud#index` and `crud#nested_index` actions lists records are already equipped with pagination, ordering and filtering.

 - You can pass `params[:sort]` with field names preffixed with `+` or `-` to configure custom ordering per request. I.E.: `?sort=+updated_at,-name`
 - You can pass `params[:q]` using [ransack's search matchers](https://github.com/activerecord-hackery/ransack#search-matchers) to build a search query. I.E.: `?q[full_name_start]=Picasso`
 - You can pass `params[:page]` and `params[:per_page]` to build pagination options. I.E.: `?page=2&per_page=12`

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ErvalhouS/APIcasso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code of conduct](http://contributor-covenant.org/).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of conduct
Everyone interacting in the Elevatore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ErvalhouS/APIcasso/blob/master/CODE_OF_CONDUCT.md).

## TODO

 - Add gem options like: Token rotation, Alternative authentication methods
 - Swagger json exporting
 - Rate limiting
 - Testing suite
 - Travis CI
