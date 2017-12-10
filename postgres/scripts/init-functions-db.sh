#!/bin/bash

if [ "`whoami`" == "root" ]; then
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
