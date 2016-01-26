#!/bin/bash

if [ ! -d "/app" ];then
	echo "Creating app from repo $REPO/$BRANCH"
	
	git clone $REPO --branch $BRANCH --single-branch /app
	cd /app
		
	# get all the gems and stuff
	bundle install
	
else
	echo "Updating app from repo $REPO"
	
	cd /app
	git pull origin $BRANCH
	
	bundle install
fi

# start the app server
RACK_ENV=$RACK_ENV bundle exec rackup -o 0.0.0.0