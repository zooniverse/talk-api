#!/bin/bash -ex

tmpreaper 7d /tmp/

ln -s /rails_conf/* /rails_app/config/ || true

if [ -f "commit_id.txt" ]
then
  cp commit_id.txt public/
fi

RUN (cd /rails_app && mkdir -p tmp/pids && rm -f tmp/pids/*.pid)
exec bundle exec puma -C config/puma.rb
