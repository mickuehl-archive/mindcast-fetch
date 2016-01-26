FROM ruby:2.2-slim
MAINTAINER Michael Kuehl <hello@ratchet.cc>

#
# BASIC DOCKERFILE
#

RUN apt-get update && apt-get -y install build-essential git postgresql-client libpq-dev
RUN gem install bundler

# add the Gemfile and bundle gems already
ADD Gemfile /Gemfile
ADD Gemfile.lock /Gemfile.lock
RUN bundle install

#
# END BASIC DOCKERFILE
#

# variables that controll the creation of the app
ENV REPO git_repo
ENV BRANCH master

# 
# default port
EXPOSE 9292

# run the script to deploy / update the app
ADD bin/run.sh /run.sh
CMD ["/run.sh"]