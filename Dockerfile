#
# Aerospike Server Enterprise Edition Dockerfile
#
# http://github.com/aerospike/aerospike-server-enterprise.docker
#

FROM debian:stretch-slim 

ENV AEROSPIKE_VERSION 5.2.0.9
ENV AEROSPIKE_SHA256 6a10210fc91d4289c532848e263b721679ba8693d15f6771d0cd6193f4284522

# Install Aerospike Server and Tools

RUN \
  apt-get update -y \
  && apt-get install -y iproute2 procps dumb-init wget python lua5.2 gettext-base libldap-dev libcurl4-openssl-dev \
  # TODO: Need to add new enterprise link. The below link cuurently needs authentication.
  && wget "https://www.aerospike.com/enterprise/download/server/${AEROSPIKE_VERSION}/artifact/debian9" -O aerospike-server.tgz \
  && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
  && dpkg -i aerospike/aerospike-server-*.deb \
  && dpkg -i aerospike/aerospike-tools-*.deb \
  && mkdir -p /var/log/aerospike/ \
  && mkdir -p /var/run/aerospike/ \
  && rm -rf aerospike-server.tgz aerospike /var/lib/apt/lists/* \
  && rm -rf /opt/aerospike/lib/java \
  && dpkg -r wget ca-certificates openssl xz-utils\
  && dpkg --purge wget ca-certificates openssl xz-utils\
  && apt-get purge -y \
  && apt autoremove -y 




# Add the Aerospike configuration specific to this dockerfile
COPY aerospike.template.conf /etc/aerospike/aerospike.template.conf
COPY entrypoint.sh /entrypoint.sh

# Mount the Aerospike data directory
# VOLUME ["/opt/aerospike/data"]
# Mount the Aerospike config directory
# VOLUME ["/etc/aerospike/"]


# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# Runs as PID 1 /usr/bin/dumb-init -- /my/script --with --args"
# https://github.com/Yelp/dumb-init

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
# Execute the run script in foreground mode
CMD ["asd"]
