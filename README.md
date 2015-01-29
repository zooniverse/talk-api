# Talk-Api

The new backend for Talk

## Setting up

* Ruby 2.2

* [Vagrant](https://www.vagrantup.com/downloads.html)

* Docker
  * [OS X](https://docs.docker.com/installation/mac/) - Boot2Docker
  * [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) - Docker
  * [Windows](http://docs.docker.com/installation/windows/) - Boot2Docker

By default, Vagrant runs in the staging environment, so you'll want to add configurations:
  * database.yml
    * ```yaml
      staging:
        <<: *default
        database: talk_staging
        username: talk
        host: <%= ENV['PG_PORT_5432_TCP_ADDR'] %>
        password: <%= ENV['TALK_DB_PASSWORD'] %>
    ```
  *  panoptes.yml
    * ```yaml
      staging:
        host: 'https://panoptes-staging.zooniverse.org'
    ```

Then start everything up with
```
  bundle
  vagrant up
  open http://localhost:3000/
```

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
* Focus (Subject, Collection)
* Moderation
* Tag
* User

## Panoptes

Talk is built to integrate with [Panoptes](https://github.com/zooniverse/panoptes)

Authentication is provided by signing your requests with a Bearer-Token

Some resources ([User](app/models/user.rb), [Collection](app/models/collection.rb), [Subject](app/models/subject.rb)) are proxied from Panoptes


## To-Do

Check the [issues](https://github.com/zooniverse/Talk-Api/issues) for what's in development.
