#!/bin/bash -ex

cd /rails_app

if [ -z "$VAGRANT_APP" ]
then
    ln -s /rails_conf/* /rails_app/config/
fi

if [ -z "$RAILS_ENV" ]
then
    export RAILS_ENV="production"
fi

exec rake db:migrate
