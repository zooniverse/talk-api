source 'https://rubygems.org'

gem 'rails', '~> 4.2.5'
gem 'rack-cors', '~> 0.4.0'
gem 'pg', '~> 0.18.4'
gem 'redis', '~> 3.2.2'
gem 'sidekiq', '~> 3.4.2'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidetiq', '~> 0.6.3'
gem 'sinatra', '~> 1.4'
gem 'restpack_serializer', github: 'parrish/restpack_serializer', branch: 'dev', ref: '05331630f3'
gem 'json-schema', '~> 2.5.2'
gem 'json-schema_builder', '~> 0.0.8'
gem 'aws-sdk', '~> 2.2.8'
gem 'faraday', '~> 0.9.2'
gem 'faraday_middleware', '~> 0.10.0'
gem 'pundit', '~> 1.0.1'
gem 'sdoc', '~> 0.4', group: :doc
gem 'spring', group: :development
gem 'newrelic_rpm', '~> 3.14'
gem 'honeybadger', '~> 2.3.2'
gem 'poseidon', '~> 0.0.5'

group :production do
  gem 'puma', '~> 2.15.3'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.4.0'
  gem 'rspec-its', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'guard-rspec', '~> 4.6.4'
  gem 'timecop'
  gem 'pry', '~> 0.10.3'
  gem 'benchmark-ips'
end

group :test do
  gem 'webmock', '~> 1.22.3'
  gem 'codeclimate-test-reporter', '~> 0.4.8'
  gem 'simplecov', '~> 0.11.1'
end
