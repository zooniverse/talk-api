require 'redis'

def self.redis_url
    ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: SidekiqConfig.redis_url }
end

concurrency = ENV.fetch('REDIS_CONCURRENCY', 5)
concurrency += 2 # for internal Sidekiq connections

require 'sidekiq'
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new size: concurrency, &connection
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new size: concurrency, &connection
  config.server_middleware do |chain|
    chain.add Sidekiq::Congestion::Limiter
  end
end

require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |name, password|
  name.present? &&
  password.present? &&
  name == ENV.fetch('SIDEKIQ_ADMIN') &&
  password == ENV.fetch('SIDEKIQ_ADMIN_PASSWORD')
end unless Rails.env.test? || Rails.env.development?

require 'sidetiq'
Sidetiq.configure do |config|
  config.utc = true
end

require 'sidetiq/web'

# preload autoloaded workers
Dir[Rails.root.join('app/workers/**/*.rb')].sort.each do |path|
  name = path.match(/workers\/(.+)\.rb$/)[1]
  name.classify.constantize unless path =~ /workers\/concerns/
end
