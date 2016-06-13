#!/usr/bin/env puma

if ENV['RAILS_ENV'] !~ /development|test/
  directory '/rails_app'
end

if ENV['RAILS_ENV'] == 'staging'
  threads 2, 5
else
  threads 2, 16
end

worker_timeout 10

bind 'tcp://0.0.0.0:81'
