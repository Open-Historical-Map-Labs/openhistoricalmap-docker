#!/bin/bash

set -e
# echo `whoami`
# apt-get -o Acquire::GzipIndexes=false update
# apt-get install -y --no-install-recommends \
  # build-essential \
  # sudo \
  # && rm -rf /var/lib/apt/lists/*

# cd /openstreetmap-website/db/functions/
# make libpgosm.so
# cd /openstreetmap-website

# sudo -u postgres -i
# psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"

until psql -d osm -c "CREATE EXTENSION btree_gist"
do
    echo "Waiting for postgres osm database ready..."
    sleep 2
done

until psql -d osm -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '/openstreetmap-website/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT"
do
    echo "Waiting for postgres osm btree_gist..."
    sleep 2
done

until psql -d osm -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '/openstreetmap-website/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT"
do
    echo "Waiting for postgres maptile_for_point..."
    sleep 2
done

until psql -d osm -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '/openstreetmap-website/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT"
do
    echo "Waiting for postgres osm tile_for_point..."
    sleep 2
done
