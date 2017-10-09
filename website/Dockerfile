FROM ruby:2.3.3
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      nodejs \
      vim \
      git-core \
      git \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /openstreetmap-website
WORKDIR /openstreetmap-website
ADD ./openstreetmap-website/Gemfile /openstreetmap-website/Gemfile
ADD ./openstreetmap-website/Gemfile.lock /openstreetmap-website/Gemfile.lock
RUN bundle install
ADD ./openstreetmap-website
