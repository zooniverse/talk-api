source 'https://rubygems.org'

gem 'aws-sdk', '~> 2.3.7'
gem 'faraday', '~> 0.9.2'
gem 'faraday_middleware', '~> 0.12.2'
gem 'honeybadger'
gem 'json-schema', '~> 2.6.2'
gem 'json-schema_builder', '~> 0.0.8'
gem 'logstasher', '~> 0.9.0'
gem 'newrelic_rpm'
gem 'pg', '~> 0.21'
gem 'pundit', '~> 1.1.0'
gem 'rack-cors', '~> 1.0.5'
gem 'rails', '~> 4.2.11'
gem 'redis'
gem 'restpack_serializer', git: 'https://github.com/zooniverse/restpack_serializer.git', branch: 'talk-api-version', ref: '637aaaf85e'
gem 'schema_plus_pg_indexes', '~> 0.1.12'
gem 'sdoc', '~> 0.4', group: :doc
gem 'sidekiq', '< 6'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidetiq', '~> 0.7.2'
gem 'sinatra', '~> 1.4'
gem 'zoo_stream', '~> 1.0'
gem 'zooniverse_social', '1.0.6'

group :production do
  gem 'puma', '~> 3.12.1'
end

group :test, :development do
  gem 'benchmark-ips'
  gem 'pry'
  gem 'spring'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.5'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'guard', '~> 2.14.0'
  gem 'guard-rspec', '~> 4.6.5'
  gem 'rspec'
  gem 'rspec-its', '~> 1.2.0'
  gem 'rspec-rails', '~> 3.4.2'
  gem 'simplecov', '~> 0.11.2'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'timecop'
  gem 'webmock', '~> 3.4'
end
