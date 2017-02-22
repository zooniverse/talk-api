#!/bin/bash -ex

cd /rails_app

if [ -z "$RAILS_ENV" ]
then
    export RAILS_ENV="production"
fi

exec rake db:migrate
