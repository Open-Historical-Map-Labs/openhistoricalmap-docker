#!/bin/bash

set -e

until psql $DATABASE_URL -c "CREATE EXTENSION IF NOT EXISTS btree_gist"
do
    echo "Waiting for postgres $POSTGRES_DATABASE database ready..."
    sleep 2
done

until psql $DATABASE_URL -f /docker-entrypoint-initdb.d/maptile_for_point.sql
do
    echo "Waiting for postgres $POSTGRES_DATABASE database ready..."
    sleep 2
done

until psql $DATABASE_URL -f /docker-entrypoint-initdb.d/tile_for_point.sql
do
    echo "Waiting for postgres $POSTGRES_DATABASE database ready..."
    sleep 2
done


