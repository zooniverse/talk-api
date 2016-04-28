require 'redis'

config = YAML.load_file('config/redis.yml')[Rails.env]
connection = -> {
  Redis.new config
}

sidekiq_config = YAML.load_file('config/sidekiq.yml').fetch Rails.env, { }
concurrency = sidekiq_config.fetch :concurrency, 5
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

sidekiq_admin = YAML.load_file 'config/sidekiq_admin.yml'

require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |name, password|
  name.present? &&
  password.present? &&
  name == sidekiq_admin['sidekiq_admin_name'] &&
  password == sidekiq_admin['sidekiq_admin_password']
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
