Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_controller.allow_forgery_protection = false
  config.serve_static_files = false
  config.force_ssl = !ENV['VAGRANT_APP']
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.active_record.raise_in_transactional_callbacks = true
  config.action_mailer.smtp_settings = YAML.load_file('config/mailer.yml')[Rails.env].symbolize_keys
  config.action_mailer.default_url_options = {
    protocol: 'https',
    host: 'www.zooniverse.org'
  }
  
  config.after_initialize do
    Rails.application.routes.default_url_options = config.action_mailer.default_url_options
  end
  
  config.logstasher.enabled = true
  config.logstasher.log_controller_parameters = true
end
