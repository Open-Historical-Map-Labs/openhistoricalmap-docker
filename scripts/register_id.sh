cmd="psql -U postgres osm -c \"INSERT INTO client_applications values('1','iD','http://localhost:3000',null,'http://localhost:3000','bzUV0OjdHUbvnABc310DF2MsDF1HLwZGdb6yhMCv','czw8tPg0Wtfc0Pfpa0JO5Esk29TP2o7OTaUJjB8q',1,now(),now(),'t','t','t','t','t','t','t');\""
docker-compose exec postgres /bin/bash -c "$cmd"
