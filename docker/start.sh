#!/bin/bash

if [ -z "$VAGRANT_APP" ]
then
    ln -s /rails_conf/* /rails_app/config/
fi

if [ "$RAILS_ENV" == "development" ]; then
  rake db:migrate
fi

exec puma
