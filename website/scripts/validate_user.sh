#!/bin/bash

# Based on instructions here:
# https://github.com/openstreetmap/openstreetmap-website/blob/master/CONFIGURE.md#managing-users

# Usage: bash validate_user.sh "username"
if [ -n "$1"]; then
  echo "USAGE:  validate_user.sh USERNAME"
  exit 1;
fi

user_name=%1

# Run the functions
bundle exec rails runner "user = User.find_by_display_name(\"$user_name\")"
bundle exec rails runner "user.status = \"active\""
bundle exec rails runner "user.save!"

