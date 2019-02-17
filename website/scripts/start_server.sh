#!/bin/bash

mkdir -p /builds

# Build iD
if [ ! -f /builds/iD ]; then
  cd  /iD

  # Remove the .git file, it causes some issues with the build process
  if [ -f /iD/.git ]; then
    rm /iD/.git
  fi

  # Run the iD build process
  npm install
  npm run all
  rm /openstreetmap-website/vendor/assets/iD/iD.js
  rm -r /openstreetmap-website/vendor/assets/iD/iD
  ln -s /iD/dist/iD.min.js /openstreetmap-website/vendor/assets/iD/iD.js
  ln -s /iD/dist/ /openstreetmap-website/vendor/assets/iD/iD
  date > /builds/iD
  cd  /openstreetmap-website
fi


# Script to make the iD changes
if [ ! -f /builds/iD_changes ]; then
  date > /builds/iD_changes
fi

# Script to make the Website changes
if [ ! -f /builds/website_changes ]; then
  date > /builds/website_changes
fi

# Bring the config files over
cp /osm-config/* /openstreetmap-website/config

# make sure the environment is set up and the images have been precompiled
rails db:environment:set RAILS_ENV=$RAILS_ENV

# Need to run rake on i18n for some updates
# https://github.com/openstreetmap/openstreetmap-website/issues/2016#issuecomment-427550933
bundle exec rake i18n:js:export

if [ ! -f /builds/images_compiled ]; then
  cd  /openstreetmap-website
  rake assets:precompile && date > /builds/images_compiled
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
