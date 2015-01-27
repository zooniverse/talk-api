#!/bin/bash

if [ -z "$VAGRANT_APP" ]
then
    ln -s /rails_conf/* /rails_app/config/
fi

bundle install --without test development
rake db:migrate
puma
