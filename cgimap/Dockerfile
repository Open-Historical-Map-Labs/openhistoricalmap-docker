FROM ubuntu:18.04
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      build-essential \
      ca-certificates \
      g++ \
      gettext \
      git \
      libboost-date-time-dev \
      libyajl-dev \ 
      libboost-dev \
      libboost-filesystem-dev \
      libboost-locale-dev \
      libboost-program-options-dev \
      libboost-regex-dev \
      libboost-system-dev \
      libcrypto++-dev \
      libfcgi-dev \
      libmemcached-dev \
      libpqxx-dev \
      libtool \
      libxml2-dev \
      lighttpd \
      make \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/zerebubuth/openstreetmap-cgimap.git
RUN cd ./openstreetmap-cgimap && \
    /bin/bash autogen.sh && \
    /bin/bash  ./configure --with-fcgi=/usr --enable-experimental
RUN cd /openstreetmap-cgimap/ && \
    make

# Add the configuration file
COPY ./lighttpd.conf /lighttpd.env.conf
COPY scripts /scripts

ENTRYPOINT /scripts/start.sh
