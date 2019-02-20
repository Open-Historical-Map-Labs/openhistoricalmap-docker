# Run OpenHistoricalMap

1. Download the submodules: `git submodule update --recursive --remote`
2. If docker-compose isn't already installed, run `bash ./scripts/install_docker.sh` 
3. Bring up the site: 

```bash
docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml build && \
  docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml up
```

If you already have an external PostgreSQL server, set its credentials as
`DATABASE_URL` in `osm-docker.env` and omit `-f
docker-compose.postgresql.yml` from the `docker-compose` commands above.

---

## Setting Up JOSM

1. Download the [JOSM .jar](https://josm.openstreetmap.de/wiki/Download)
2. Once downloaded, doubleclick on the .jar to load it
3. Go to “MainApplication” > “Preferences”
4. Click the second tab down on the left-hand side: “Connection Settings”
5. Change the “OSM Server URL” to: http://www.openhistoricalmap.org/api
6. Under “Authentication” below, switch to “Use Basic Authentication” and enter credentials you just setup in the "OpenStreetMap Website" section above
7. Click “OK”
8. Use JOSM to download data
