# syntax=docker/dockerfile:1.4

ARG DEEPHAVEN_TAG=latest

FROM ghcr.io/deephaven/server:${DEEPHAVEN_TAG}
RUN pip install --no-cache-dir --only-binary=:all: websocket-client
COPY --link app.d /opt/deephaven/config/app.d

# TODO: we are unable to use layout in the config directory of our choice
# because it's currently tied to the data storage layout
# COPY --link layouts /opt/deephaven/config/layout
COPY --link layouts /data/storage/layouts

# We need to hack around it and expose it as a separate volume so it
# doesn't get overwritten by the /data volume
VOLUME /data/storage/layouts

# Unable to specify this as part of configuration file ATM
ENV START_OPTS="-Ddeephaven.application.dir=/opt/deephaven/config/app.d"
