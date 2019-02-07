#!/bin/bash

# make sure the environment is set up and the images have been precompiled
rails db:environment:set RAILS_ENV=$RAILS_ENV
if [ ! -f /images_compiled ]; then
  rake assets:precompile && touch /images_compiled
fi

cd  /openstreetmap-website
if ! grep -Fq 'gem "passenger"' /openstreetmap-website/Gemfile
  then
    echo 'gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"' >> /openstreetmap-website/Gemfile
fi
bundle update --conservative "passenger"
cp /osm-config/* /openstreetmap-website/config
mkdir -p /openstreetmap-website/tmp/pids/
rm /openstreetmap-website/tmp/pids/*
bundle exec rails server -p $RAILS_SERVER_PORT -b '0.0.0.0'
