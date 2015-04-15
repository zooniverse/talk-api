require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Talk
  class Application < Rails::Application
    config.autoload_paths += [
      'lib',
      'app/services',
      'app/services/concerns',
      'app/serializers/concerns',
      'app/serializers',
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
