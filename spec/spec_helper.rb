ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV.keys.grep(/aws/i).each{ |key| ENV.delete key }

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'json/schema_builder/rspec'
require 'webmock/rspec'
require 'sidekiq/testing'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!
Sidekiq::Testing.fake!
PanoptesUser = User # Since RSpec/FactoryGirl can't handle multiple databases

Aws.config.update region: 'us-east-1', credentials: Aws::Credentials.new('', '')

$required_validation_text = Rails.version.starts_with?('4.2') ? "can't be blank" : "must exist"

if ENV['EVIL_MODE']
  require 'open-uri'

  File.open('spec/support/awful_strings.json', 'wb') do |out|
    open('https://raw.githubusercontent.com/minimaxir/big-list-of-naughty-strings/master/blns.json', 'rb') do |data|
      out.write data.read
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include JSON::SchemaBuilder::RSpecHelper, type: :schema
  MOCK_REDIS ||= MockRedis.new

  config.before(:suite){ WebMock.disable_net_connect! }
  config.after(:suite){ WebMock.allow_net_connect! }

  config.before(:each) do |example|
    allow(Redis).to receive(:new).and_return(MOCK_REDIS)

    MOCK_REDIS.keys.each do |key|
      MOCK_REDIS.del(key)
    end

    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end
