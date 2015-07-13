#!/usr/bin/env puma

directory '/rails_app'

threads 2, 16
worker_timeout 10

bind 'tcp://0.0.0.0:80'
