# Talk-Api

The new backend for Talk

[![Build Status](https://travis-ci.org/zooniverse/Talk-Api.svg?branch=master)](https://travis-ci.org/zooniverse/Talk-Api)
[![Code Climate](https://codeclimate.com/github/zooniverse/Talk-Api/badges/gpa.svg)](https://codeclimate.com/github/zooniverse/Talk-Api)
[![Test Coverage](https://codeclimate.com/github/zooniverse/Talk-Api/badges/coverage.svg)](https://codeclimate.com/github/zooniverse/Talk-Api)

## Setting up

* Ruby 2.2

* [Vagrant](https://www.vagrantup.com/downloads.html)

* Docker
  * [OS X](https://docs.docker.com/installation/mac/) - Boot2Docker
  * [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) - Docker
  * [Windows](http://docs.docker.com/installation/windows/) - Boot2Docker

By default, Vagrant runs in the staging environment, so you'll want to add configurations:

* database.yml
  ```yaml
    staging:
      adapter: postgresql
      encoding: unicode
      pool: 5
      database: talk_staging
      username: talk
      host: <%= ENV['PG_PORT_5432_TCP_ADDR'] %>
      password: <%= ENV['TALK_DB_PASSWORD'] %>
  ```

* panoptes.yml
  ```yaml
    staging:
      host: 'https://panoptes-staging.zooniverse.org'
  ```

* secrets.yml
  ```yaml
    staging:
      secret_key_base: <%= ENV['SECRET_KEY_BASE'] %>
  ```

Then start everything up with
```
  bundle
  vagrant up
  open http://localhost:3000/
```

If you're running outside of vagrant and just want to run the specs ensure you've created all the databases and tables(foreign) via the following commands:
1. `RACK_ENV=test bundle exec rake db:create`
0. `RACK_ENV=test bundle exec rake db:schema:load`
0. `RACK_ENV=panoptes_test bundle exec rake db:create`
0. `RACK_ENV=test bundle exec rake panoptes:db:create_tables`
0. `RACK_ENV=test bundle exec rake panoptes:db:setup`

See *.travis.yml* for more details.

## Layout

The app is built to conform to the [JSON API spec](http://jsonapi.org/)

* Serializers - [app/serializers](app/serializers)
  * Uses [RestPack Serializer](https://github.com/RestPack/restpack_serializer)
  * What attributes are included in the response `?user_id=1234`
  * What associations can be side loaded `?include=comments,board`
  * What links can be followed from the resource


* Policies - [app/policies](app/policies)
  * Uses [Pundit](https://github.com/elabs/pundit)
  * Who has permissions to perform actions
  * What records are visible to a user


* Schemas - [app/schemas](app/schemas)
  * Uses [JSON Schema](https://github.com/ruby-json-schema/json-schema) and [JSON Schema Builder](https://github.com/parrish/json-schema_builder)
  * Conforms to the [JSON Schema spec](http://json-schema.org/)
  * What request structure is expected and allowed in create and update actions

## Resources

* Board
* Comment
* Conversation
* Discussion
* Moderation
* Subject
* Tag
* User

## Panoptes

Talk is built to integrate with [Panoptes](https://github.com/zooniverse/panoptes)

Authentication is provided by signing your requests with a Bearer-Token

Some resources ([User](app/models/user.rb), [Subject](app/models/subject.rb)) are proxied from Panoptes


## To-Do

Check the [issues](https://github.com/zooniverse/Talk-Api/issues) for what's in development.


## License

Copyright 2014-2015 by the Zooniverse

Distributed under the Apache Public License v2. See [LICENSE](LICENSE)

[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)
