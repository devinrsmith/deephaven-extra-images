# syntax=docker/dockerfile:1.4

ARG DEEPHAVEN_TAG=latest

FROM --platform=$BUILDPLATFORM web-plugin-packager as packager
ARG NPM_PACKAGES
RUN ./pack-plugins.sh ${NPM_PACKAGES}

FROM ghcr.io/deephaven/server:${DEEPHAVEN_TAG}
ARG PYTHON_PACKAGES
RUN pip install --no-cache-dir --only-binary=:all: ${PYTHON_PACKAGES}
COPY --link --from=packager js-plugins/ /opt/deephaven/config/js-plugins/
COPY --link deephaven.prop /opt/deephaven/config/deephaven.prop
