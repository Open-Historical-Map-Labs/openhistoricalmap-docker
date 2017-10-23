#!/bin/bash

# Find extracts here:
# Metro: https://mapzen.com/data/metro-extracts/
# States / Countries: http://download.geofabrik.de/
$URL=https://s3.amazonaws.com/metro-extracts.mapzen.com/denver-boulder_colorado.osm.pbf

docker-compose exec postgres /bin/bash /scripts/populate_database.sh "$URL"
