# PostgreSQL Btree-gist Extension
## We need to load the btree-gist extension, which is needed for showing changesets on the history tab.

# PostgreSQL Functions

## We need to install special functions into the PostgreSQL databases, and these are provided by a library that needs compiling first.

# Then we create the functions within each database. We're using pwd to substitute in the current working directory, since PostgreSQL needs the full path.
declare -a databases=("osm" "openstreetmap" "osm_test" "root")
set -e

for db in "${databases[@]}"
do
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER $db WITH SUPERUSER PASSWORD '$db' CREATEDB;
    CREATE DATABASE $db OWNER $db;
    CONNECT $db;
    "CREATE EXTENSION btree_gist;
    CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT;
    CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT;
    CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT;
EOSQL
done
