#!/bin/bash

bundle install --without test development
rake db:migrate
puma
