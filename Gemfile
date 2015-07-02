source 'https://rubygems.org'

gem 'rails', '~> 4.2.1'
gem 'rack-cors', '~> 0.3.1'
gem 'pg', '~> 0.18.1'
gem 'redis', '~> 3.2.1'
gem 'sidekiq', '~> 3.3.3'
gem 'sidekiq-congestion'
gem 'sidetiq', '~> 0.6.3'
gem 'sinatra', '~> 1.4'
gem 'restpack_serializer', github: 'parrish/restpack_serializer', branch: 'dev', ref: '05331630f3'
gem 'json-schema', '~> 2.5.0'
gem 'json-schema_builder', '~> 0.0.5'
gem 'faraday', '~> 0.9.1'
gem 'faraday_middleware', '~> 0.9.1'
gem 'faraday-http-cache', '~> 1.1.0'
gem 'pundit', '~> 0.3.0'
gem 'sdoc', '~> 0.4', group: :doc
gem 'spring', group: :development
gem 'newrelic_rpm', '~> 3.11'
gem 'honeybadger', '~> 2.0.10'

group :production do
  gem 'puma', '~> 2.11.1'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.1.0'
  gem 'rspec-its', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'guard-rspec', '~> 4.5.0'
  gem 'pry', '~> 0.10.1'
end

group :test do
  gem 'webmock', '~> 1.21.0'
  gem 'codeclimate-test-reporter', '~> 0.4.7'
  gem 'simplecov', '~> 0.9.2'
end
