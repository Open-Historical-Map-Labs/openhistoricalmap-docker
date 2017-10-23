#!/bin/bash

# Based on instructions here:
# https://github.com/openstreetmap/openstreetmap-website/blob/master/CONFIGURE.md#managing-users

# Usage: bash validate_user.sh "username"
if [ -n "$1"]; then
  echo "USAGE: validate_user.sh USERNAME"
  exit 1;
fi

includes_dir=/includes

# TODO: Read this from CONFIG
dbnameapi=osm
user=osm
pass=osm

dbExtractPath=/extracts
dbfile=extract.osm.pbf
dbfileUrl=%1

echo -e "\033[34m"
echo "╔═════════════════════════════════════════════════════════════════╗"
echo "║  Install Osmosis                                                ║"
echo "╟─────────────────────────────────────────────────────────────────╢"
echo "║  Some of this information can be found here:                    ║"
echo "║     http://wiki.openstreetmap.org/wiki/Osmosis#Latest_Stable_Version"
echo "╚═════════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"
echo ""
mkdir -p $includes_dir/osmosis
cd $includes_dir/osmosis

echo -e "\033[33m──━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──\033[0m"
echo            "  Installing Java and unzip tools"
echo -e "\033[33m──━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──\033[0m"

apt-get -y update
apt-get -y install unzip openjdk-6-jdk curl
rm -rf /var/lib/apt/lists/*

echo -e "\033[33m──━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──\033[0m"
echo            "  Downloading and extracting Osmosis"
echo -e "\033[33m──━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━──\033[0m"
if [ -a "osmosis-latest.zip" ]; then
  rm osmosis-latest.zip
fi
curl -O http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.zip
unzip osmosis-latest.zip
ln -s ./bin/osmosis /usr/bin/osmosis

# Download the extract
mkdir -p $includes_dir$dbExtractPath
dbfile_full=$includes_dir$dbExtractPath/$dbfile
if [ -a $dbfile_full ]; then
  rm $dbfile_full
fi
curl -o $dbfileUrl $dbfile_full

# Load the file into the database
$includes_dir/osmosis/bin/osmosis --read-pbf file="$dbfile_full" --write-apidb  database="$dbnameapi" user="$user" password="$pass" validateSchemaVersion=no
# $includes_dir/osmosis/bin/osmosis --read-pbf file="$includes_dir/data/$dbfile" --write-pgsql  database="$dbnamepgs" user="$user" password="$pass"
