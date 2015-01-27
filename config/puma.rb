#!/usr/bin/env puma

directory '/rails_app'

threads 0, 16
worker_timeout 60

bind 'tcp://0.0.0.0:80'

# on_restart do
#   
# end

# restart_command '/rails_app/docker/restart_puma'

# workers 2

# on_worker_boot do
#   
# end

# after_worker_boot do
#   
# end

# on_worker_shutdown do
#   
# end

# Allow workers to reload bundler context when master process is issued
# a USR1 signal. This allows proper reloading of gems while the master
# is preserved across a phased-restart. (incompatible with preload_app)
# (off by default)

# prune_bundler

# Preload the application before starting the workers; this conflicts with
# phased restart feature. (off by default)

# preload_app!
