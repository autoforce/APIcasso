<img src="https://raw.githubusercontent.com/ErvalhouS/APIcasso/master/APIcasso.png" width="300" /> [![Gem Version](https://badge.fury.io/rb/apicasso.svg)](https://badge.fury.io/rb/apicasso) [![Docs Coverage](https://inch-ci.org/github/autoforce/APIcasso.svg?branch=master)](https://inch-ci.org/github/autoforce/APIcasso.svg?branch=master) [![Maintainability](https://api.codeclimate.com/v1/badges/b58bbd6b9a0376f7cfc8/maintainability)](https://codeclimate.com/github/autoforce/APIcasso/maintainability) [![codecov](https://codecov.io/gh/autoforce/APIcasso/branch/master/graph/badge.svg)](https://codecov.io/gh/autoforce/APIcasso) [![Build Status](https://travis-ci.org/autoforce/APIcasso.svg?branch=master)](https://travis-ci.org/autoforce/APIcasso)

Create APIs in a fast and dynamic way, without the need to develop everything from scratch. You just need to create your models and let **APIcasso** do the rest for you. It is the perfect candidate to make your project development go faster or for legacy Rails projects that do not have an API.

If you think it through, JSON API development can get boring and time consuming. Every time you use almost the same route structure, pointing to the same controller actions, with the same ordering, filtering and pagination features.

**APIcasso** is intended to be used to speed-up development, acting as a full-fledged CRUD JSON API into all your models. It is a route-based abstraction that lets you create, read, list, update or delete any `ActiveRecord` object in your application. This makes it possible to make CRUD-only applications just by creating functional Rails' models. Access to your application's resources is managed by a `.scope` JSON object per API key. It uses that permission scope to restrict and extend access.

You can make your own API with only 4 steps:

### Step 1
 Create your models
### Step 2
 Insert **APIcasso** engine into your routes
### Step 3
 [Create an Apicasso::Key](https://github.com/autoforce/APIcasso#authorization)
### Step 4
 Profit! :crown: Consume your REST API


# Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'apicasso'
```

And then execute this to generate the required migrations:

```bash
$ bundle install && rails g apicasso:install
```

# Requirements

 - PostgreSQL with JSON columns support
 - Ruby 2.3+

# Usage

**APIcasso** is meant to be used as an engine, which means you don't need to configure any route or controller to build a working CRUD API. Sometimes you also need some customized controller actions or even a specific logic to access some of your application's resources. In that case you will use `Apicasso::CrudController` class to easily build only your own logic around the API abstraction.

## Mounting engine into `config/routes.rb`

After installing it, you can mount a full-fledged CRUD JSON API just by attaching into some route. Usually you will have it under a scoped route like `/api/v1` or a subdomain. You can do that by adding this into your `config/routes.rb`:

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

## Extending base API actions

When your application needs some kind of custom interaction that is not covered by APIcasso's CRUD approach you can make your own actions using our base classes and objects to go straight into your logic. If you have built the APIcasso's engine into a route it is important that your custom action takes precedence over the gem's ones. To do that you need to declare your custom route before the engine on you `config/routes.rb`

```ruby
  match '/:resource/:id/a-custom-action' => 'custom#not_a_crud', via: :get
  mount Apicasso::Engine, at: "/api/v1"
```

And in your `app/controllers/custom_controller.rb` you would have something like:

```ruby
  class CustomController < Apicasso::CrudController
    def not_a_crud
      render json: @object.some_operation
    end
  end
```

This way you enjoy all our object finder, authorization and authentication features, making your job more straight into your business logic.

## Authentication

> But exposing my models to the internet is permissive as hell! Haven't you thought about security?

_Sure!_ The **APIcasso** suite is exposing your application using authentication through `Authorization: Token` [HTTP header authentication](http://tools.ietf.org/html/draft-hammer-http-token-auth-01). The API key objects are manageable through the `Apicasso::Key` model, which gets setup at install. When a new key is created a `.token` is generated using an [Universally Unique Identifier(RFC 4122)](https://tools.ietf.org/html/rfc4122). An authenticated request looks like this:

```
curl -X GET \
  https://apixample.com/v1/your_app_resource \
  -H 'authorization: Token token=cda4e9f633c123ef9ddce5e6564292b3'
```

Each `Apicasso::Key` object has a token attribute, which is used on this header to authorize access. For now, there is no plans for a login/JWT logic, you should implement this in your project's scope.

## Authorization

Your Models are then exposed based on each `Apicasso::Key.scope` definition, which is a way to configure how much of your application each key can access. I.E.:

```ruby
  Apicasso::Key.create(scope:
                        { manage:
                            { order: true, user: { account_id: 1 } },
                          read:
                            { account: { manager_id: 1 } }
                        })
```

> The key from this example will have full access to all orders and to users with `account_id == 1`. It will have also read-only access to accounts with `id == 1`.

A scope configured like this translates directly into which kind of access each key has on all of your application's models. This kind of authorization is why one of the dependencies for this gem is [CanCanCan](https://github.com/CanCanCommunity/cancancan), which abstracts the scope field into your API access control.

You can have two kind of access control:

- `true` - This will mean the key will have the declared clearance on **ALL** of this model's records
- `Hash` - This will build a condition to what records this key have access to. A scope as `{ read: [{ account: { manager_id: 1 } }] }` will have read access into accounts with `manager_id == 1`

This saves you the trouble of having to setup every controller for each model. And even if your application really needs it, just make your controllers inherit from `Apicasso::CrudController` extending it and enabling the use of `@object` and `@resource` variables to access what is being resquested.

## Features on index actions

The index actions present in the gem are already equipped with pagination, ordering, grouping, fieldset selection and filtering. This will save you a lot of trouble, adding some best-practices conventions into your application's API.

### Sort

You can sort a collection query by using a URL parameter with field names preffixed with `+` or `-` to configure custom ordering per request.

To order a collection with ascending `updated_at` and descending `name` you can add the `sort` parameter with those fields as options, indicating which kind of ordination you want to give to each one:

```
?sort=+updated_at,-name
```

### Filtering/Search

APIcasso has [ransack's search matchers](https://github.com/activerecord-hackery/ransack#search-matchers) on it's index actions. This means you can dynamically build search queries with any of your resource's fields, this will be done by using a `?q` parameter which groups all your filtering options on your requests. If you wanted to search all your records and return only the ones with `full_name` starting with `Picasso` your query would look something like this:

```
?q[full_name_start]=Picasso
```

To build complex search queries you can chain many parameter options or check [ransack's wiki](https://github.com/activerecord-hackery/ransack/wiki/) on how to adapt this feature into your project's needs.

### Pagination

Automatic pagination is done in index actions, with the adittion of some metadata to help on the data consumption. You can pass page and per page parameters to build pagination options into your needs. And on requests that you need unpaginated collections, just pass a lower than zero `per_page`. Example of a pagination query string:

```
?page=2&per_page=12
```

Your colletion will be build inside a JSON along with some metadata about it. The response structure is:

```
{ entries: [{Record1}, {Record2}, {Record3} ... {Record12}],
  total: 1234,
  total_pages: 102,
  last_page: false,
  previous_page: localhost:3000/my_records?page=1&per_page=12,
  next_page: localhost:3000/my_records?page=3&per_page=12,
  out_of_bounds: false,
  offset: 12 }
```

### Fieldset selecting

Sometimes your data can grow large in some tables and you need to consumed only a limited set of data on a given frontend application. To avoid large requests and filtering a lot of unused data with JS you can restrict which fields you need on your API's reponse. This is done adding a `?select` parameter. Just pass the field names you desire splitted by `,`
Let's say you are building a user list with their name, e-mails and phones, to get only those fields your URL query would look something like:

```
?select=name,email,phone
```

This will change the response to return only the requested attributes. You need to observe that your business logic may require some fields for a valid response to be returned. **This method can be used both on index and show actions**

### Including relations or methods on response

If there is any method or relation that you want to be inserted on the payload, you just need to pass them as a part of the URL query like this:

```
?include=pictures,suggestions
```

This will insert the contents of `.pictures` and `.suggestions` on the payload, along with the records' data. This means you can populate the payload both with methods or relations contents. **This method can be used both on index and show actions**

### Grouping operations

If you need to make grouping calculations, like:

- Counting of all records, or by one **optional** field presence
- Maximum value of one field
- Minimum value of one field
- Average value of one field
- Value sum of one field

Grouping is done by the combination of 3 parameters

```
?group[by]=a_field&group[calculate]=count&group[fields]=another_field
```

Each of those attributes on the `?group` parameter represent an option of the query being made.

- `group[by]` - Represents which field will be the key for the grouping behavior
- `group[calculate]` - Which calculation will be sent in the response. Options are: `count`, `maximum`, `minimum`, `average`, `sum`
- `group[field]` - Represents which field will be the base for the response calculation.

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ErvalhouS/APIcasso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code of conduct](http://contributor-covenant.org/). To find good places to start contributing, try looking into our issue list and our Codeclimate profile, or if you want to participate actively on what the core team is working on checkout our todo list:

### TODO

- Add support to other databases
- [Abstract a configurable CORS approach, maybe using middleware](https://github.com/autoforce/APIcasso/issues/22)
- Add gem options like: Token rotation, Alternative authentication methods
- Refine and document auto-documentation feature
- Rate limiting

# Code of conduct

Everyone interacting in the APIcasso project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ErvalhouS/APIcasso/blob/master/CODE_OF_CONDUCT.md).

# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
