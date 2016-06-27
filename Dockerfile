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
 && : \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
 && :

ADD https://apt.mopidy.com/jessie.list /etc/apt/sources.list.d/mopidy.list
ADD https://apt.mopidy.com/mopidy.gpg /tmp/mopidy.gpg

RUN set -xv \
 && apt-key add /tmp/mopidy.gpg \
 && : \
 && apt-get update \
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
		python-setuptools \
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

# entrypoint baby
COPY entrypoint /

# ~~~ all past here runs as mopidy ~~~
USER mopidy

COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

VOLUME /var/lib/mopidy/local
VOLUME /var/lib/mopidy/media

EXPOSE 6600 6680
ENTRYPOINT ["/entrypoint"]
CMD ["/usr/bin/mopidy"]
