#!/bin/bash

# Create the OSM user account
export PGPASSWORD=$POSTGRES_PASSWORD

set -e

until psql -U $POSTGRES_USER -h $POSTGRES_HOST -p $POSTGRES_PORT -d $POSTGRES_DATABASE -c "CREATE EXTENSION IF NOT EXISTS btree_gist"
do
    echo "Waiting for postgres $POSTGRES_DATABASE database ready..."
    sleep 2
done
