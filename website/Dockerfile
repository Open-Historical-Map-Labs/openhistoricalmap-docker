FROM ruby:2.3
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      sudo \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://deb.nodesource.com/setup_7.x | sudo bash -
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      vim \
      git-core \
      git \
      libmagickwand-dev \
      libxml2-dev \ 
      libxslt1-dev \
      apache2 \
      apache2-dev \
      libpq-dev  \
      libsasl2-dev \
      imagemagick \
      nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g svgo imagemin-svgo
RUN mkdir -p /openstreetmap-website
RUN mkdir -p /osm-config
WORKDIR /openstreetmap-website
ADD ./openstreetmap-website/Gemfile /openstreetmap-website/Gemfile
ADD ./openstreetmap-website/Gemfile.lock /openstreetmap-website/Gemfile.lock
ADD ./config/* /osm-config/
RUN echo 'gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"' >> /openstreetmap-website/Gemfile
RUN bundle install
