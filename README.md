# APIcasso
JSON API development can get boring and time consuming. If you think it through, every time you make one you use almost the same route structure pointing the same controller actions, with the same features: ordering, filtering and pagination.
APIcasso is intended to be used as a full-fledged CRUD JSON API or as a base controller. It makes development and easier job by abstracting route-based resource operations into API key scoping. This makes it possible to make CRUD-only applications just by creating functional Rails' models. The magic is done by a `.scope` JSON object which exists in every API key. It uses permission scopes as keys to restrict and extend APIcasso access to your application's resources.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'apicasso'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install apicasso
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
