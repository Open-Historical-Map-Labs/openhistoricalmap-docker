# Internal OpenStreetMap Instance
## Summary
This project uses docker-compose to define and run a multi-container Docker application. Docker is an application that runs containers as an abstraction on top of the operating system kernel. These tools are used to orchestrate a full OpenStreetMap server, include its front end, back end, and databases.

The docker-compose application opens two ports, `3000` and `5432`. Port `3000` connects to the Nginx server, which proxies most requests to the Website server, but requests for large amounts of map data get routed through the faster CGI map server. Port `5432` connects to the rendering database’s PostgreSQL instance. To connect to anything else inside the containers, see the section at the bottom labeled “Connecting to the Containers”.

## Environment Variables and Customizations

The API 0.6 database login information:
```
POSTGRES_DATABASE=osm
POSTGRES_USER=osm
POSTGRES_PASSWORD=osm
```

The Website parameters. (The SECRET KEY BASE can be anything)
```
RAILS_ENV=production
SECRET_KEY_BASE=10d52b1bf88c429e73ffbc5e5f58b037db21f38ea88b8b454e55d52ed8bcc6e7fe3b48a79b2f36eb78a4685224d707767d083f79c51f7d81a9d4a06d1c1e2534
SERVER_PORT=3000
```

The iD connection strings, these are also somewhat arbitrary
```
ID_KEY=bzUV0OjdHUbvnABc310DF2MsDF1HLwZGdb6yhMCv
ID_SECRET=czw8tPg0Wtfc0Pfpa0JO5Esk29TP2o7OTaUJjB8q
ID_WEBSITE=http://localhost
```

The name of the database used for rendering:
```
POSTGISDB_NAME=osm
```

## Containers
### “postgres”
Base Image: `postgres:9.6.6`
#### Customizations:
This image uses the base image as-is. There are three scripts included in the “./postgres/scripts” directory and the postgres data directory is mapped to “./postgres/data”.
#### Scripts:
* init-functions-db.sh
  * Initialize functions: Installs the software required to build the OpenStreetMap spatial indexing functions and it builds the functions.
* init-id.sh
  * Initialize User Database: Creates a database to be used with the OSM data and adds the OSM spatial indexing functions.
* init-user-db.sh
  * Initialize iD: Creates a dummy user with OSM user name of “PLACEHOLDER” and id of 0, it then registers the iD application to this user using the information in the osm-docker.env file.
### “rendering_database”
Base Image: `postgres:10`
#### Customizations:
This image uses the base postgres:10 image and then installs PostGIS 2.4 on it. It also installs the OpenStreetMap tools osm2psql and osmosis. Both tools are used to run Extract, Transform, and Load (ETL) functions using OpenStreetMap data. This is on a separate image to make it easier to prevent rendering processes from taking resources from the main API.

This tool uses [osm2pqsql](https://wiki.openstreetmap.org/wiki/Osm2pgsql) in conjunction with osmosis as opposed to the [imposm tool](https://wiki.openstreetmap.org/wiki/Imposm) because imposm 2 doesn’t have the replication support. [Imposm 3](https://github.com/omniscale/imposm3) looks like it will be a better option to use than osm2pgsql, but it has not yet been released.

This image also includes a cron task that is started by the “init-rendering-db.sh” script, and runs the “render_task.sh” task every minute.
#### Configuration Files:
* “postgresql.conf”
  * An update to the PostGIS database config file that contains changes making the database more efficient with the OpenStreetMap schema.
  * The source material for these optimizations can be found here: https://wiki.openstreetmap.org/wiki/PostgreSQL
  * Since this implementation is using PostGIS version 10, more information on tuning can be found here: https://www.postgresql.org/docs/10/static/runtime-config-resource.html
#### Scripts:
* init-rendering-db.sh
  *  Initialize Rendering Database
     1.  Creates the “gis” database
     2.  Copies the configuration file “postgresql.conf” to its proper location
     3.  Runs the “render_task.sh” script with the “--no-append” option in order to create the proper database schema
     4.  Starts the cron task
* render_task.sh
  * The task to “render” data from the OpenStreetMap (API 0.6 schema) into PostGIS (PGSnapshot Schema)
    1.  Creates a filename for the temporary file as `{SYSTEM TIME}.osm`
    2.  Runs Osmosis to get the latest changes from the APIDB database and write them into the `{SYSTEM TIME}.osm` file. Also updates the time in the log file: `/osm_data/last_osmosis_run`
    3.  Runs `osm2pgsql` in slim mode which reads the `{SYSTEM TIME}.osm` file and writes the changes to the PGSnapshot database. Also updates time in the log file: `/osm_data/last_osm2pgsql_run`
    4.  If everything ran successfully, it will delete the `{SYSTEM TIME}.osm` file
#### Troubleshooting:
If the render database and the OSM main database become “out of sync”, it is possible to wipe the database and start from the beginning. Use the following steps to do this:
  1.  Log into the container with “docker-compose rendering_database exec bash”.
  2.  Stop the automatic CRON task with the command `/etc/init.d/cron stop`
  3.  Remove the `/root/state.txt` file
  4.  Run the following command: `/bin/bash /docker-entrypoint-initdb.d/render_task.sh $POSTGRES_USER $POSTGRES_PASSWORD $POSTGRES_DATABASE $POSTGISDB_NAME`
  5.  After the process completes, start the CRON task up with `etc/init.d/cron start`
### “website”
Base Image: `ruby:2.3`
#### Customizations:
This image uses the standard ruby 2.3 imge and adds nodejs support as well as a number of image processing packages. It also installs the “openstreetmap-website” respository.

The “openstreetmap-website” repository has been modified to automatically register new users without requiring an email.

There are two configuration files found within the website/config directory
* application.yml
  * This controls settings that may be important to running the web server, such as the main URL, website name, and other system level variables.
* database.yml
  * This includes the database login information for the development, test, and production servers.
Scripts:
* start_server.sh	
  * Makes sure that passenger is installed and runs the OpenStreetMap server through Passenger
### “cgimap”
Base Image: `Ubuntu:16.04`
#### Customizations:
This image uses the base LTS Ubuntu image (as is suggested in the documentation for cgimap) and installs all the components needed for the CGI Map tool (https://github.com/openstreetmap/cgimap).

CGI Map is an optimization tool for downloading large amounts of data from the OpenStreetMap API 0.6 servers. This is used every time the map is panned in iD. The original Ruby code for this function is slow and uses excessive resources. CGImap is run through a lighttpd server.

It contains one configuration file:
* "lighttpd.conf”
  * Contains the database login information for the API 0.6 (postgres) server
#### Scripts:
* “start.sh”
  * A simple script that is used to start the lighttpd server
### “nginx”
Base Image: `nginx:1.13.8-alpine`
#### Customizations:
This image uses the most basic nginx image and supplies it with a custom config file. The Nginx server is used to route most API messages to the website container, but certain messages will be routed to the CGImap server for faster processing.
 
## Connecting to the containers:

To connect to any of the containers, use the command: `docker-compose {container name} exec bash`

In the case of the nginx container, which doesn’t have bash installed use `sh` with the command `docker-compose nginx exec sh`. This will give you console access to each machine, and is very useful for debugging.
