#!/bin/bash

# Create the OSM user account
psql -U postgres -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"

set -e

until psql -U postgres -d $POSTGISDB_NAME -c "CREATE EXTENSION IF NOT EXISTS btree_gist"
do
    echo "Waiting for postgres $POSTGISDB_NAME database ready..."
    sleep 2
done

until psql -U postgres -d $POSTGISDB_NAME -c "CREATE OR REPLACE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '/openstreetmap-website/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT"
do
    echo "Waiting for postgres $POSTGISDB_NAME btree_gist..."
    sleep 2
done

until psql -U postgres -d $POSTGISDB_NAME -c "CREATE OR REPLACE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '/openstreetmap-website/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT"
do
    echo "Waiting for postgres maptile_for_point..."
    sleep 2
done

until psql -U postgres -d $POSTGISDB_NAME -c "CREATE OR REPLACE FUNCTION xid_to_int4(xid) RETURNS int4 AS '/openstreetmap-website/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT"
do
    echo "Waiting for postgres $POSTGISDB_NAME tile_for_point..."
    sleep 2
done
