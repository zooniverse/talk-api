source 'https://rubygems.org'

gem 'rails', '~> 4.2.0.rc1'
gem 'pg'
gem 'restpack_serializer', '~> 0.5.6'
gem 'pundit', '~> 0.3'
gem 'sdoc', '~> 0.4', group: :doc
gem 'spring', group: :development

group :test, :development do
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'rb-fsevent' if `uname` =~ /Darwin/
  gem 'pry'
end
