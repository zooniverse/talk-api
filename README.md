# Talk-Api

The new backend for Talk

[![Build Status](https://travis-ci.org/zooniverse/Talk-Api.svg?branch=master)](https://travis-ci.org/zooniverse/Talk-Api)
[![Code Climate](https://codeclimate.com/github/zooniverse/Talk-Api/badges/gpa.svg)](https://codeclimate.com/github/zooniverse/Talk-Api)
[![Test Coverage](https://codeclimate.com/github/zooniverse/Talk-Api/badges/coverage.svg)](https://codeclimate.com/github/zooniverse/Talk-Api)
[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

## Setting up
* Docker
  * [OS X](https://docs.docker.com/installation/mac/) - Boot2Docker
  * [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) - Docker
  * [Windows](http://docs.docker.com/installation/windows/) - Boot2Docker

Build & start the docker containers:

```
  docker-compose build
  docker-compose up
  open http://localhost:3000/
```

Alternatively use docker to run a testing environment bash shell and run test commands, run:

1. `docker-compose run --service-ports --rm -e RAILS_ENV=test talkapi bash`
2. Setup the test database **
    1. `RAILS_ENV=test bundle exec rake db:create`
    2. `RAILS_ENV=test bundle exec rake db:schema:load`
    3. `RAILS_ENV=panoptes_test bundle exec rake db:create`
    4. `RAILS_ENV=test bundle exec rake panoptes:db:create_tables`
    5. `RAILS_ENV=test bundle exec rake panoptes:db:setup`
3. `bundle exec rspec`

** See *.travis.yml* for more details on how to setup the talk database.

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
