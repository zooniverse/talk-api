#!/usr/bin/env puma

if ENV['RAILS_ENV'] !~ /development|test/
  directory '/rails_app'
end

threads 1, ENV.fetch('RAILS_MAX_THREADS', 2).to_i
worker_timeout 10

bind 'tcp://0.0.0.0:81'
