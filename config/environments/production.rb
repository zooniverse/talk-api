Rails.application.configure do
  config.cache_classes = true
  config.cache_store = :memory_store, { size: 64.megabytes }
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_controller.allow_forgery_protection = false
  config.public_file_server.enabled = false
  config.force_ssl = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.smtp_settings = {
    enable_starttls_auto: true,
    address: ENV['MAILER_ADDRESS'],
    port: ENV.fetch('MAILER_PORT', 587).to_i,
    domain: ENV['MAILER_DOMAIN'] || 'zooniverse.org',
    authentication: ENV.fetch('MAILER_AUTHENTICATION', 'plain'),
    user_name: ENV['MAILER_USER_NAME'],
    password: ENV['MAILER_PASSWORD']
  }

  config.action_mailer.default_url_options = {
    protocol: 'https',
    host: 'www.zooniverse.org'
  }

  config.after_initialize do
    Rails.application.routes.default_url_options = {
      protocol: 'https',
      host: 'talk.zooniverse.org'
    }
  end

  # Enable the logstasher logs for the current environment
  config.logstasher.enabled = true
  # Enable logging of controller params
  config.logstasher.log_controller_parameters = true
  # log to stdout
  config.logstasher.logger = Logger.new(STDOUT)
  # turn off rails logs
  config.logstasher.suppress_app_log = true
end
