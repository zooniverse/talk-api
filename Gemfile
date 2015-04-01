source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'rack-cors', '~> 0.2.9'
gem 'pg'
gem 'restpack_serializer', github: 'parrish/restpack_serializer', branch: 'dev'
gem 'json-schema', '~> 2.5'
gem 'json-schema_builder', '~> 0.0.5'
gem 'faraday', '~> 0.9'
gem 'faraday_middleware', '~> 0.9'
gem 'faraday-http-cache', '~> 0.4'
gem 'pundit', '~> 0.3'
gem 'sdoc', '~> 0.4', group: :doc
gem 'spring', group: :development
gem 'newrelic_rpm', '~> 3.11'
gem 'honeybadger', '~> 2.0'

group :production do
  gem 'puma'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'pry'
end

group :test do
  gem 'webmock'
  gem 'codeclimate-test-reporter'
  gem 'simplecov'
end
