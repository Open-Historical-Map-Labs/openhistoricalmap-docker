FROM ruby:2.3
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      apache2 \
      apache2-dev \
      build-essential \
      git \
      git-core \
      imagemagick \
      jhead \
      libmagickwand-dev \
      libpq-dev  \
      libpq-dev \
      libsasl2-dev \
      libxml2-dev \ 
      libxslt1-dev \
      nodejs \
      vim \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g \
      advpng-bin \
      gifsicle \
      imagemin-svgo \
      img-optim \
      jpegoptim-bin \
      jpegtran-bin \
      optipng-bin \
      pngcrush-bin \
      pngquant-bin \
      svgo
RUN mkdir -p /openstreetmap-website
RUN mkdir -p /osm-config
WORKDIR /openstreetmap-website
ADD ./openstreetmap-website/Gemfile /openstreetmap-website/Gemfile
ADD ./openstreetmap-website/Gemfile.lock /openstreetmap-website/Gemfile.lock
ADD ./config/* /osm-config/
RUN echo 'gem "passenger", ">= 5.0.25", require: "phusion_passenger/rack_handler"' >> /openstreetmap-website/Gemfile
RUN bundle install
