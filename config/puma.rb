#!/usr/bin/env puma

directory '/rails_app'

if ENV['RAILS_ENV'] == 'staging'
  threads 2, 5
else
  threads 2, 16
end

worker_timeout 10

bind 'tcp://0.0.0.0:81'
