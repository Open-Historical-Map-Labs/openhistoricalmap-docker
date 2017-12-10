#!/bin/bash

cd  /openstreetmap-website
if ! grep -Fq 'gem "passenger"' /openstreetmap-website/Gemfile
  then
    echo 'gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"' >> /openstreetmap-website/Gemfile
fi
bundle update --conservative "passenger"
rm /openstreetmap-website/tmp/pids/*
bundle exec rails server -p $SERVER_PORT -b '0.0.0.0'
