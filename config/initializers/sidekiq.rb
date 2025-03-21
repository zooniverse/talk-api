module SidekiqConfig
  def self.redis_url
    ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: SidekiqConfig.redis_url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: SidekiqConfig.redis_url }
  config.server_middleware do |chain|
    chain.add Sidekiq::Congestion::Limiter
  end

  # Sidekiq-cron: loads recurring jobs from config/schedule.yml
  schedule_file = 'config/schedule.yml'
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |name, password|
  name.present? &&
  password.present? &&
  name == ENV.fetch('SIDEKIQ_ADMIN_NAME') &&
  password == ENV.fetch('SIDEKIQ_ADMIN_PASSWORD')
end unless Rails.env.test? || Rails.env.development?

# preload autoloaded workers after database has been loaded
# See: https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots

Rails.application.config.to_prepare do
  db_loaded = ::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false

  if db_loaded
    Dir[Rails.root.join('app/workers/**/*.rb')].sort.each do |path|
      name = path.match(/workers\/(.+)\.rb$/)[1]
      name.classify.constantize unless path =~ /workers\/concerns/
    end
  end
end
