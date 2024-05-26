# Talk-Api

![Build Status](https://github.com/zooniverse/talk-api/actions/workflows/run_tests_CI.yml/badge.svg?branch=master)

The new backend for Talk

## Setting up
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)

Build & start the docker containers:

```
  docker-compose build
  docker-compose up
  open http://localhost:3000/
```

Alternatively use docker to run a testing environment bash shell and run test commands, run:

1. `docker-compose run --service-ports --rm -e RAILS_ENV=test talkapi bash`
2. Install the gem dependencies for the application `bundle install`
3. Setup the test database **
    1. `RAILS_ENV=test bundle exec rake db:create`
    2. `RAILS_ENV=test bundle exec rake db:schema:load`
    3. `RAILS_ENV=panoptes_test bundle exec rake db:create`
    4. `RAILS_ENV=test bundle exec rake panoptes:db:create_tables`
    5. `RAILS_ENV=test bundle exec rake panoptes:db:setup`
4. `bundle exec rspec`

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

## Setting Up Rails-next
Using the gem https://github.com/clio/ten_years_rails to help with the upgrade path https://www.youtube.com/watch?v=6aCfc0DkSFo

### Using docker-compose for env setup

```
docker-compose -f docker-compose-rails-next.yml build

docker-compose -f docker-compose-rails-next.yml run --service-ports --rm -e RAILS_ENV=test talkapi bash
```

### Install the gems via next

`BUNDLE_GEMFILE=Gemfile.next bundle install`

OR

`next bundle install`


## To-Do

Check the [issues](https://github.com/zooniverse/Talk-Api/issues) for what's in development.


## License

Copyright 2014-2015 by the Zooniverse

Distributed under the Apache Public License v2. See [LICENSE](LICENSE)
