#!/bin/bash

# Install the database for osm2pgsql
 if [ "`whoami`" == "root" ]; then
   # Set up database optimizations
   # https://wiki.openstreetmap.org/wiki/PostgreSQL
   # http://www.geofabrik.de/media/2012-09-08-osm2pgsql-performance.pdf
   # cp /conf/postgresql.conf  /var/lib/postgresql/data/postgresql.conf
   # /etc/init.d/postgresql reload

   # Add the iD key
   psql -U postgres -d $APIDB_NAME -c "INSERT INTO users (email, id, pass_crypt, creation_time, display_name) VALUES('placeholder@example.com',0,'PLACEHOLDER',now(),'PLACEHOLDER');"
   psql -U postgres -d $APIDB_NAME -c "INSERT INTO client_applications VALUES('1','iD','$ID_WEBSITE',null,'$ID_WEBSITE','$ID_KEY','$ID_SECRET',0,now(),now(),'t','t','t','t','t','t','t');"
 fi
