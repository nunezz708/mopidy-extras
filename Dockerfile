FROM ubuntu
MAINTAINER Trevor Joynson <docker@trevor.joynson.io>

ADD common/bin /usr/local/bin/
RUN image-prep

ENV APP_USER=app \
    APP_HOME=/app

RUN set -exv \
 && lazy-apt --no-install-recommends \
      gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-tools \
      xdg-user-dirs xdg-utils \
 && :

RUN set -exv \
 && curl -sL https://apt.mopidy.com/mopidy.gpg \
    | apt-key add - \
 && lazy-apt-repo mopidy https://apt.mopidy.com/mopidy.list \
 && lazy-apt --no-install-recommends \
    $(apt-cache search '^mopidy-.*' | sed -e 's/ .*$//' | egrep -v 'gpodder|doc') \
 && :

RUN set -exv \
 && cleanup=no lazy-apt --no-install-recommends \
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
 && cleanup=no lazy-apt-with --no-install-recommends \
        libgmp-dev build-essential python-dev python-pip python-wheel \
 -- pip install \
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
        #Mopidy-LeftAsRain \
        Mopidy-Party \
        #Mopidy-Headless \
        #Mopidy-Cd \
        #Mopidy-Pandora \
        #Mopidy-Tidal \
        #Mopidy-Serial \
        Mopidy-AlarmClock \
        #Mopidy-Plex \
        #Mopidy-Local-Whoosh \
        MopidyCLI \
        Mopidy-WebSettings \
        #Mopidy-ALSAMixer \
        #mopidy-lcd \
        #Mopidy-Headspring-Web \
        #Mopidy-Tachikoma \
 && : \
 && apt-get purge -y \
        gcc-5 gcc g++-5 patch make xz-utils binutils cpp-5 libatomic1 '.*-dev$' \
 && apt-get autoremove -y \
 && apt-get autoremove -y \
 && apt-get autoremove -y \
 && image-cleanup

COPY image $APP_HOME/image
RUN ln -sfv $APP_HOME/image/entrypoint /

USER $APP_USER

ENV PULSE_SERVER="tcp:localhost:4713" \
    PULSE_COOKIE_DATA="" \
    PULSE_COOKIE="" \
    XDG_CONFIG_HOME="$APP_HOME/.config" \
    XDG_CACHE_HOME="$APP_HOME/.cache" \
    XDG_DATA_HOME="$APP_HOME/.local/share" \
    XDG_MUSIC_DIR="$APP_HOME/Music" \
    #XDG_RUNTIME_DIR="/run/user/1000" \
    APP_UID=1000

VOLUME $XDG_DATA_HOME/mopidy $XDG_CONFIG_HOME

EXPOSE 6600 6680
ENTRYPOINT ["/entrypoint"]
CMD ["mopidy"]

ADD run docker-compose.yml README.md $APP_HOME/host/

# delevate down to $APP_USER in entrypoint after fixing up perms
USER root

