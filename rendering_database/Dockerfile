FROM postgres:10

# Add PostGIS and postgresql contribs
RUN apt-get update  -qq && \
      apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      ca-certificates \
      postgresql-10-postgis-2.4 \
      postgresql-10-postgis-2.4-scripts \
      osm2pgsql \
      osmosis \
      vim \
       && rm -rf /var/lib/apt/lists/*
