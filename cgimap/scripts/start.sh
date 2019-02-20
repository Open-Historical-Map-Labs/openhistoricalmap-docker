#! /bin/bash

envsubst < /lighttpd.env.conf > /lighttpd.conf
lighttpd -f /lighttpd.conf &
/bin/bash
