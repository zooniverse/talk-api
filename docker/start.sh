#!/bin/bash -ex

tmpreaper 7d /tmp/

ln -s /rails_conf/* /rails_app/config/ || true

if [ -f "commit_id.txt" ]
then
  cp commit_id.txt public/
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/talk.conf
