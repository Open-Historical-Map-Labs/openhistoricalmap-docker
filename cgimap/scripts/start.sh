#!/bin/bash

envsubst '$POSTGRES_HOST $POSTGRES_DATABASE $POSTGRES_USER $POSTGRES_PASSWORD' < /lighttpd.env.conf > /lighttpd.conf
lighttpd -f /lighttpd.conf -D
