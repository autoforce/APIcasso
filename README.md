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

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ErvalhouS/APIcasso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code of conduct](http://contributor-covenant.org/).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of conduct
Everyone interacting in the Elevatore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ErvalhouS/APIcasso/blob/master/CODE_OF_CONDUCT.md).
