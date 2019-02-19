#!/bin/bash

mkdir -p /builds

# Build iD
if [ ! -f /builds/iD ]; then
  cd  /iD

  # Move the .git file, it causes some issues with the build process
  if [ -f /iD/.git ]; then
    mv /iD/.git /iD/tmp.git
  fi

  # Run the iD build process
  npm install
  npm translations
  npm run all
  rm /openstreetmap-website/vendor/assets/iD/iD.js
  rm -r /openstreetmap-website/vendor/assets/iD/iD
  ln -s /iD/dist/iD.min.js /openstreetmap-website/vendor/assets/iD/iD.js
  ln -s /iD/dist/ /openstreetmap-website/vendor/assets/iD/iD
  date > /builds/iD

  # Move the .git file back
  if [ -f /iD/tmp.git ]; then
    mv /iD/tmp.git /iD/.git
  fi

  cd  /openstreetmap-website
fi

# Bring the config files over
cp /osm-config/* /openstreetmap-website/config

# make sure the environment is set up and the images have been precompiled
cd  /openstreetmap-website
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

mkdir -p /openstreetmap-website/tmp/pids/
rm /openstreetmap-website/tmp/pids/*
bundle exec rails server -p $OSM_server_port -b '0.0.0.0'
