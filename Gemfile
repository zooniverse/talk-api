def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

if next?
  gem 'rails', '5.1.7'
else
  gem 'rails', '5.1.7'
end

gem 'aws-sdk', '~> 2.3.7'
gem 'faraday'
gem 'faraday_middleware'
gem 'honeybadger', '~> 4.5.0'
gem 'json-schema', '~> 2.8'
gem 'json-schema_builder', '~> 0.0.8'
gem 'logstasher', '~> 0.9.0'
gem 'newrelic_rpm'
gem 'pg', '~> 0.21'
gem 'puma'
gem 'pundit', '~> 1.1.0'
gem 'rack-cors', '~> 1.0.5'
gem 'redis', '~> 3.3.0'
gem 'restpack_serializer', git: 'https://github.com/zooniverse/restpack_serializer.git', branch: 'talk-api-version', ref: '637aaaf85e'
gem 'schema_plus_pg_indexes'
gem 'sidekiq', '< 6'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidekiq-cron'
gem 'spring', group: :development
gem 'zoo_stream', '~> 1.0'

group :test, :development do
  gem 'benchmark-ips'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'ffi', '1.16.3'
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 4.1.2' # upgrade when on rails 5.2
  gem 'spring-commands-rspec'
  gem 'ten_years_rails'
  gem 'timecop'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.5'
  gem 'mock_redis'
  gem 'simplecov', '~> 0.11.2'
  gem 'webmock', '~> 3.4'
end
