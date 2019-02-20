# Move the configs
sudo cp ./website/config/* ./website/openstreetmap-website/config/

# Build the dockers
echo "Building Docker"
docker-compose build
echo "Bring Docker Up"
docker-compose up -d

# Create the database
echo "pg functions: create the database"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-functions-db.sh
echo "add pg user info and associate the functions to the database"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-user-db.sh
echo "website: migrating database"
docker-compose exec website bundle exec rake db:migrate
echo "add the key to iD"
docker-compose exec postgres /bin/bash /docker-entrypoint-initdb.d/init-id.sh
# Disable testing in the production environment (can be destructive to data)
# echo "website testing"
# docker-compose exec website bundle exec rake test:db

echo "Restart the website"
docker-compose stop website && docker-compose start website

echo "Navigate your browser to http://localhost:3000"
