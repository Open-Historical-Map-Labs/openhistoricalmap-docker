docker-compose exec postgres /bin/bash -c "psql -U postgres osm -c \"update users set status = 'active' where status = 'pending';\""
