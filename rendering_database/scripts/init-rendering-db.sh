#!/bin/bash

# Install the database for osm2pgsql
 if [ "`whoami`" == "root" ]; then

   # Set up the rendering Database
   psql -U postgres -c "CREATE DATABASE $POSTGISDB_NAME;"
   psql -U postgres -d $POSTGISDB_NAME -c "CREATE EXTENSION postgis;"
   psql -U postgres -d $POSTGISDB_NAME -c "CREATE EXTENSION postgis_topology;"
   psql -U postgres -d $POSTGISDB_NAME -c "CREATE EXTENSION hstore;"
   mkdir -p /osm_data
   # curl -o ~/schema.sql https://raw.githubusercontent.com/openstreetmap/osmosis/master/package/script/pgsnapshot_schema_0.6.sql
   # psql -U postgres -d $POSTGISDB_NAME -f ~/schema.sql
   # rm ~/schema.sql

   # Set up database optimizations
   # https://wiki.openstreetmap.org/wiki/PostgreSQL
   # http://www.geofabrik.de/media/2012-09-08-osm2pgsql-performance.pdf
   cp /config/postgresql.conf  /var/lib/postgresql/data/postgresql.conf
   /etc/init.d/postgresql reload

   # Add rendering tasks to CRON
   crontab -r
   (crontab -l 2>/dev/null; echo "* * * * * /bin/bash /docker-entrypoint-initdb.d/render_task.sh") | crontab -
   /etc/init.d/cron restart
 fi
