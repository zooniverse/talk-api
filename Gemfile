source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'rack-cors', '~> 1.0.5'
gem 'pg', '~> 0.21'
gem 'redis', '~> 3.3.0'
gem 'sidekiq', '< 6'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidetiq', '~> 0.7.2'
gem 'restpack_serializer', git: 'https://github.com/zooniverse/restpack_serializer.git', branch: 'talk-api-version', ref: '637aaaf85e'
gem 'json-schema', '~> 2.8'
gem 'json-schema_builder', '~> 0.0.8'
gem 'aws-sdk', '~> 2.3.7'
gem 'faraday'
gem 'faraday_middleware'
gem 'pundit', '~> 1.1.0'
gem 'spring', '~> 1.7.1', group: :development
gem 'newrelic_rpm'
gem 'honeybadger', '~> 4.5.0'
gem 'logstasher', '~> 0.9.0'
gem 'zoo_stream', '~> 1.0'
gem 'schema_plus_pg_indexes', '~> 0.1.12'
gem 'puma'

group :test, :development do
  gem 'rspec-rails', '~> 3.4.2'
  gem 'rspec-its', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'guard', '~> 2.14.0'
  gem 'guard-rspec', '~> 4.6.5'
  gem 'timecop'
  gem 'pry', '~> 0.11.3'
  gem 'benchmark-ips'
end

group :test do
  gem 'webmock', '~> 3.4'
  gem 'codeclimate-test-reporter', '~> 0.5'
  gem 'simplecov', '~> 0.11.2'
end