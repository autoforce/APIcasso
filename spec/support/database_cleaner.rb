RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.after(:suite) do
    DatabaseCleaner.strategy = :truncation, { :only => %w[apicasso_keys] }
    DatabaseCleaner.clean
  end
end
