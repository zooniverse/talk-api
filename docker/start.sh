#!/bin/bash -ex

tmpreaper 7d /tmp/

ln -s /rails_conf/* /rails_app/config/ || true

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/talk.conf
