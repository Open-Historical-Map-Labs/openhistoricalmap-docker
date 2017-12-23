#!/bin/bash

if [ "`whoami`" == "root" ]; then
  apt-get update  -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-contrib-9.6 \
    postgresql-server-dev-9.6 \
    postgresql-9.6-postgis-2.4 \
    osm2pgsql \
    curl \
     && rm -rf /var/lib/apt/lists/*
  cd /openstreetmap-website/db/functions
  make libpgosm.so
fi
