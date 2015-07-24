require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Talk
  class BannedUserError < StandardError
    def message
      'You are banned'
    end
    alias_method :to_s, :message
  end
  
  class InvalidParameterError < StandardError
    def initialize(param, expected, actual)
      @param = param
      @expected = expected
      @actual = actual
    end
    
    def message
      "Expected #{ @param } to be #{ @expected }, but was #{ @actual }"
    end
    alias_method :to_s, :message
  end
  
  class Application < Rails::Application
    config.autoload_paths += [
      'lib',
      'app/schemas/concerns',
      'app/schemas',
      'app/services/concerns',
      'app/services',
      'app/serializers/concerns',
      'app/serializers',
      'app/workers/concerns',
      'app/workers'
    ].collect{ |path| Rails.root.join path }
    
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any,
          methods: [:options, :get, :post, :put, :delete],
          expose: ['ETag']
      end
    end
  end
end
