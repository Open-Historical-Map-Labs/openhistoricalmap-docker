#!/bin/bash

# Bring the config files over
cp /osm-config/* /openstreetmap-website/config

# make sure the environment is set up and the images have been precompiled
rails db:environment:set RAILS_ENV=$RAILS_ENV

# Need to run rake on i18n for some updates
# https://github.com/openstreetmap/openstreetmap-website/issues/2016#issuecomment-427550933
bundle exec rake i18n:js:export

if [ ! -f /images_compiled ]; then
  cd  /openstreetmap-website
  rake assets:precompile && touch /images_compiled
fi

cd  /openstreetmap-website
if ! grep -Fq 'gem "passenger"' /openstreetmap-website/Gemfile
  then
    echo 'gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"' >> /openstreetmap-website/Gemfile
fi

# Run this twice, to make sure passenger gets installed
bundle update --conservative
bundle update --conservative "passenger"
mkdir -p /openstreetmap-website/tmp/pids/
rm /openstreetmap-website/tmp/pids/*
bundle exec rails server -p $RAILS_SERVER_PORT -b '0.0.0.0'
