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
echo "pg user info (associate the functions to the database)"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-user-db.sh
echo "website env"
docker-compose exec website rails db:environment:set RAILS_ENV=production
echo "website pre-compile images"
docker-compose exec website bash -c "export RAILS_ENV=production && rake assets:precompile"
echo "website migrating database"
docker-compose exec website bundle exec rake db:migrate
echo "set up iD"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-id.sh
echo "set up rendering database"
docker-compose exec rendering_database /bin/bash /docker-entrypoint-initdb.d/init-rendering-db.sh
# Disable testing in the production environment (can be destructive to data)
# echo "website testing"
# docker-compose exec website bundle exec rake test:db

echo "Restart the website"
docker-compose stop website && docker-compose start website

echo "Navigate your browser to http://localhost:3000"
