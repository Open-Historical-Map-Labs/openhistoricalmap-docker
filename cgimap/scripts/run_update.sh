#!/bin/bash

# export the data from the api_db and run it into osm2pgsql, then remove the file
osmosis \
  --replicate-apidb \
    host=$POSTGRES_HOST \
    user=$POSTGRES_USER \
    password=$POSTGRES_PASSWORD \
    database=$POSTGRES_DATABASE \
    validateSchemaVersion=no \
  --replication-to-change \
  --write-xml-change \
    $MINUTELY_FILE_DEST
