#!/bin/bash

docker-compose exec website /bin/bash /scripts/validate_user.sh %1
