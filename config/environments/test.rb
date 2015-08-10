Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
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
end
