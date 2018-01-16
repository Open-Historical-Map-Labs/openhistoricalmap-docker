#!/bin/bash
USER="$1"
PASSWORD="$2"
DATABASE="$3"
POSTGISDB="$4"

# Check for the state file, if none exists, create one
# if we're creating one, we're going back to the begining of time,
#    so we will not be appending the database
state_file=./state.txt
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
if [ -f $state_file ]; then
  append='--append'
  echo "append"
else
  append=''
  cp $SCRIPTPATH/initial_state.txt $state_file
  echo "new, `pwd` - `ls $state_file`"
fi

# http://www.geofabrik.de/media/2012-09-08-osm2pgsql-performance.pdf

# Name the temporary .osm file
file=/osm_data/$(date +%s).osm

# Log the last run time to a file so we can always find it
date > /last_cron_run

# export the data from the api_db and run it into osm2pgsql, then remove the file
# TODO: make this more robust (loop through failed runs, maybe set a semaphore)
osmosis \
  --replicate-apidb \
    host=postgres \
    user=$USER \
    password=$PASSWORD \
    database=$DATABASE \
    validateSchemaVersion=no \
  --replication-to-change \
  --write-xml-change \
    $file > /osm_data/last_osmosis_run 2>&1 \
  && \
    osm2pgsql \
      --slim \
      $append \
      -U postgres \
      -d $POSTGISDB \
    $file > /osm_data/last_osm2pgsql_run 2>&1 \
  && \
    rm $file
