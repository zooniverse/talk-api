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
      'app/services'
    ].collect{ |path| Rails.root.join path }
  end
end
