Rails.application.configure do
  config.cache_classes = false
  config.cache_store = :memory_store, { size: 64.megabytes }
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  # Don't care if the mailer can't send emails in dev
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    protocol: 'http',
    host: 'localhost',
    port: 3000
  }

  config.after_initialize do
    Rails.application.routes.default_url_options = config.action_mailer.default_url_options
  end

  # override default log to stdout, unless env var key exists
  unless ENV.key?('RAILS_LOG_TO_FILE')
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end
end
