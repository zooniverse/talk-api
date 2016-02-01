FROM zooniverse/ruby:2.3.0

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

WORKDIR /rails_app

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y supervisor git libpq-dev && \
    apt-get clean


ADD ./Gemfile /rails_app/
ADD ./Gemfile.lock /rails_app/

RUN cd /rails_app && \
    bundle install --without test development

ADD ./ /rails_app

ADD docker/supervisor.conf /etc/supervisor/conf.d/talk.conf

RUN (cd /rails_app && git log --format="%H" -n 1 > commit_id.txt && rm -rf .git)

EXPOSE 81

ENTRYPOINT /usr/bin/supervisord
