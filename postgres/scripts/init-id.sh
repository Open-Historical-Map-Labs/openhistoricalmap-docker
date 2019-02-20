#!/bin/bash

# Add the iD key
psql $DATABASE_URL -c "INSERT INTO users (email, id, pass_crypt, creation_time, display_name) VALUES('placeholder@example.com',0,'PLACEHOLDER',now(),'PLACEHOLDER');"
psql $DATABASE_URL -c "INSERT INTO client_applications VALUES('1','iD','$OSM_id_website',null,'$OSM_id_website','$OSM_id_key','$OSM_id_secret',0,now(),now(),'t','t','t','t','t','t','t');"