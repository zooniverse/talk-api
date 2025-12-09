def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

if next?
  gem 'rails', '7.1.6'
else
  gem 'rails', '7.0.8.7'
end

gem 'aws-sdk-kinesis', '~> 1'
gem 'aws-sdk-s3', '~> 1'
# lock concurrent-ruby to 1.3.4 since 1.3.5 breaks active support
# with a NameError  uninitialized constant
# ActiveSupport::LoggerThreadSafeLevel::Logger on application.rb
# See: https://github.com/rails/rails/issues/54260
# It looks like this gets fixed in Rails 7.1
gem 'concurrent-ruby', '1.3.4'
gem 'faraday'
gem 'faraday_middleware'
gem 'honeybadger', '~> 4.5.0'
gem 'json-schema', '~> 2.8'
gem 'json-schema_builder', git: 'https://github.com/zooniverse/json-schema_builder.git', branch: 'talk-version', ref: '5e39cae16a'
gem 'logstasher', '~> 0.9.0'
gem 'newrelic_rpm'
gem 'pg'
gem 'puma'
gem 'pundit', '~> 1.1.0'
gem 'rack-cors', '~> 1.0.5'
gem 'redis', '~> 3.3.0'
gem 'restpack_serializer', git: 'https://github.com/zooniverse/restpack_serializer.git', branch: 'talk-api-version', ref: 'ef87bcf1fafe'
gem 'sidekiq', '< 6'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidekiq-cron'
gem 'spring', group: :development
gem 'zoo_stream', '~> 1.1'

group :test, :development do
  gem 'benchmark-ips'
  gem 'factory_bot_rails'
  gem 'ffi', '1.16.3'
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'ten_years_rails'
  gem 'timecop'
end

group :test do
  gem 'mock_redis'
  gem 'simplecov'
  gem 'webmock', '~> 3.4'
end
