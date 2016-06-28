FROM ubuntu

MAINTAINER Trevor Joynson <docker@trevor.joynson.io>

RUN set -xv \
 && apt-get update \
 && : \
 && apt-get install -y --no-install-recommends \
        #gstreamer0.10-alsa \
        #alsa-base \
        #gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-pulseaudio \
        #gstreamer1.0-tools \
        #libdvdnav4 libglib2.0-data shared-mime-info xml-core file \
        #xdg-user-dirs \
        gosu \
 && : \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
 && :

ADD https://apt.mopidy.com/jessie.list /etc/apt/sources.list.d/mopidy.list
ADD https://apt.mopidy.com/mopidy.gpg /tmp/mopidy.gpg

ENV APP_USER=app \
    APP_HOME=/app

RUN set -xv \
 && apt-key add /tmp/mopidy.gpg \
 && : \
 && apt-get update \
 && : \
 && useradd -U -G audio -d "$APP_HOME" -s /bin/bash -m -u 1000 "$APP_USER" \
 && : \
 && apt-get install -y --no-install-recommends \
        mopidy \
        $(apt-cache search '^mopidy-.*' | sed -e 's/ .*$//' | egrep -v 'mpris|doc') \
 && : \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
 && :

RUN set -xv \
 && apt-get update \
 && : \
 && apt-get install -y --no-install-recommends \
        python-ndg-httpsclient \
        python-openssl \
        python-crypto \
        python-cryptography \
        python-beautifulsoup \
        python-six \
        python-cffi \
        #libffi-dev \
        #libssl-dev \
        python-setuptools \
		libnotify-bin \
        \
        libgmp10 \
        \
        libgmp-dev build-essential python-dev python-pip python-wheel \
 && : \
 && pip install \
        pafy \
        Mopidy-GMusic \
        Mopidy-Moped \
        Mopidy-API-Explorer \
        Mopidy-Material-Webclient \
        #Mopidy-Mobile \
        Mopidy-Mopify \
        Mopidy-MusicBox-Webclient \
        Mopidy-Spotmop \
        mopidy-notifier \
        Mopidy-Webhooks \
        Mopidy-AudioAddict \
 && : \
 && apt-get purge -y \
        gcc-5 gcc g++-5 patch make xz-utils binutils cpp-5 libatomic1 '.*-dev$' \
        libgmp-dev build-essential python-dev python-pip python-wheel \
 && apt-get autoremove -y \
 && apt-get autoremove -y \
 && apt-get autoremove -y \
 && : \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* ~/.cache \
 && :

COPY image/entrypoint /

USER $APP_USER

ENV PULSE_SERVER="tcp:0.0.0.0:4713" \
    PULSE_COOKIE_DATA="" \
    PULSE_COOKIE="" \
    XDG_CONFIG_HOME="$APP_HOME/.config" \
    XDG_CACHE_HOME="$APP_HOME/.cache" \
    XDG_DATA_HOME="$APP_HOME/.local/share" \
    XDG_RUNTIME_DIR="/tmp"

VOLUME $XDG_DATA_HOME/mopidy $XDG_CONFIG_HOME
COPY image/mopidy.conf $APP_HOME/mopidy.conf.default

EXPOSE 6600 6680
ENTRYPOINT ["/entrypoint"]
CMD ["mopidy"]

ADD run docker-compose.yml README.md $APP_HOME/host/

# delevate down to $APP_USER in entrypoint after fixing up perms
USER root
