# frozen_string_literal: true

app_path = File.expand_path(File.dirname(File.dirname(__FILE__)))
dev_env = 'development'
rails_env = ENV.fetch('RAILS_ENV', dev_env)
port = rails_env == dev_env ? 3000 : 81
threads_count = ENV.fetch('RAILS_MAX_THREADS', 2).to_i

# PUMA DSL settings
pidfile "#{app_path}/tmp/pids/server.pid"
state_path "#{app_path}/tmp/pids/puma.state"
threads 1, threads_count
bind "tcp://0.0.0.0:#{port}"
tag 'talk_api'
