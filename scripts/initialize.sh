# Move the configs
sudo cp ./website/config/* ./website/openstreetmap-website/config/

# Build the dockers
echo "Building"
docker-compose build
echo "Upping"
docker-compose up -d

# Create the database
echo "pg functions"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-functions-db.sh
echo "website env"
docker-compose exec website rails db:environment:set RAILS_ENV=production rake assets:precompile
echo "website creating"
# The DB should already be created at this point
# docker-compose exec website bundle exec rake db:create
echo "website pre-compile images"
docker-compose exec website rails RAILS_ENV=production rake assets:precompile
echo "website migrating"
docker-compose exec website bundle exec rake db:migrate
# echo "website testing"
# docker-compose exec website bundle exec rake test:db

