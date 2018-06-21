source 'https://rubygems.org'

gem 'rails', '~> 4.2.7'
gem 'rack-cors', '~> 0.4.0'
gem 'pg', '~> 0.18.4'
gem 'redis', '~> 3.3.5'
gem 'sidekiq', '~> 4.1.2'
gem 'sidekiq-congestion', '~> 0.1.0'
gem 'sidetiq', '~> 0.7.0'
gem 'sinatra', '~> 1.4'
gem 'restpack_serializer', git: 'https://github.com/parrish/restpack_serializer.git', branch: 'dev', ref: 'f2b93bb415'
gem 'json-schema', '~> 2.6.2'
gem 'json-schema_builder', '~> 0.0.8'
gem 'aws-sdk', '~> 2.3.7'
gem 'faraday', '~> 0.9.2'
gem 'faraday_middleware', '~> 0.10.0'
gem 'pundit', '~> 1.1.0'
gem 'sdoc', '~> 0.4', group: :doc
gem 'spring', '~> 1.7.1', group: :development
gem 'newrelic_rpm', '~> 3.15'
gem 'honeybadger', '~> 2.6.0'
gem 'logstasher', '~> 0.9.0'
gem 'zoo_stream', '~> 1.0'
gem 'zooniverse_social', '1.0.6'
gem 'schema_plus_pg_indexes', '~> 0.1.12'

group :production do
  gem 'puma', '~> 3.4.0'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.4.2'
  gem 'rspec-its', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'guard', '~> 2.14.0'
  gem 'guard-rspec', '~> 4.6.5'
  gem 'timecop'
  gem 'pry', '~> 0.10.3'
  gem 'benchmark-ips'
end

group :test do
  gem 'webmock', '~> 2.0'
  gem 'codeclimate-test-reporter', '~> 0.5'
  gem 'simplecov', '~> 0.11.2'
end
