Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.raise_in_transactional_callbacks = true
  config.action_mailer.smtp_settings = YAML.load_file('config/mailer.yml')[Rails.env].symbolize_keys
  config.action_mailer.default_url_options = {
    protocol: 'http',
    host: 'localhost',
    port: 3000
  }

  config.after_initialize do
    Rails.application.routes.default_url_options = config.action_mailer.default_url_options
  end

  config.logstasher.enabled = true
  config.logstasher.log_controller_parameters = true
end
