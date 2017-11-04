FROM trevorj/boilerplate:zesty
MAINTAINER Trevor Joynson <docker@trevor.joynson.io>

COPY requirements/base.* requirements/
RUN install-reqs requirements/base.*

COPY requirements requirements

COPY build.d build.d
RUN build-parts build.d

COPY image image
COPY run docker-compose.yml README.md ./host/

ENV PULSE_SERVER="tcp:localhost:4713" \
    PULSE_COOKIE_DATA="" \
    PULSE_COOKIE="" \
    CONFIG_DIR="/config" \
    DATA_DIR="/data" \
    CACHE_DIR="/cache" \
    PULSE_DIR="/pulse"

EXPOSE 6600 6680 6681
CMD ["mopidy"]

VOLUME $CONFIG_DIR $DATA_DIR $CACHE_DIR $PULSE_DIR

# Healthcheck on the HTTP port
# Disabled: Fucking Circle is so out of date. Ugh.
#HEALTHCHECK --interval=5m --timeout=3s CMD curl -sSLf http://localhost:6680
