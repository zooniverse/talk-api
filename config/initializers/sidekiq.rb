require 'redis'

config = YAML.load_file('config/redis.yml')[Rails.env]
connection = -> {
  Redis.new config
}

require 'sidekiq'
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new size: 10, &connection
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new size: 10, &connection
  config.server_middleware do |chain|
    chain.add Sidekiq::Congestion::Limiter
  end
end

require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |name, password|
  name.present? &&
  password.present? &&
  name == ENV['SIDEKIQ_ADMIN_NAME'] &&
  password == ENV['SIDEKIQ_ADMIN_PASSWORD']
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
