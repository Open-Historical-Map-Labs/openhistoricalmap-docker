#!/bin/bash

apt-get update -qq > /dev/null 2>&1
if [ $? -eq 0 ]; then
  # Add postgresql contribs in order to build libpgosm.so
  apt-get update  -qq && \
      apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-contrib-9.6 \
      postgresql-server-dev-9.6 \
       && rm -rf /var/lib/apt/lists/*

  cd /openstreetmap-website/db/functions
  make libpgosm.so
fi
