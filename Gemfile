def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

if next?
  gem 'rails', '5.0.7.2'
  gem 'schema_plus_pg_indexes', '~> 0.2.1'
  gem 'spring', '~> 2.0.2', group: :development
else
  gem 'rails', '~> 4.2'
  gem 'schema_plus_pg_indexes', '~> 0.1.12'
  gem 'spring', '~> 1.7.1', group: :development
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
gem 'sidekiq', '< 6'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidetiq', '~> 0.7.2'
gem 'zoo_stream', '~> 1.0'

group :test, :development do
  if next?
    gem 'rspec-rails', '~> 4.1.2'
  else
    gem 'rspec-rails', '~> 3.4.2'
  end
  gem 'benchmark-ips'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'guard', '~> 2.14.0'
  gem 'guard-rspec', '~> 4.6.5'
  gem 'pry', '~> 0.11.3'
  gem 'rspec-its', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'ten_years_rails'
  gem 'timecop'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.5'
  gem 'simplecov', '~> 0.11.2'
  gem 'webmock', '~> 3.4'
end
