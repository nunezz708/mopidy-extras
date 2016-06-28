Containerized [**Mopidy**](https://www.mopidy.com/) music server with support for [MPD clients](https://docs.mopidy.com/en/latest/clients/mpd/) and [HTTP clients](https://docs.mopidy.com/en/latest/ext/web/#ext-web).

Originally a fork of https://github.com/wernight/docker-mopidy, but has been highly modified since.

### Features

  * Based on `Ubuntu` official (`ubuntu:latest`)
  * Extremely easy to add new plugins through PR, most are just a single line addition to the `Dockerfile`.
  * Backend extensions:
    * Standards: DLNA(dLeyna)
    * [Mopidy-Spotify](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-spotify) for **[Spotify](https://www.spotify.com/us/)** (Premium)
    * [Mopidy-GMusic](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-gmusic) for **[Google Play Music](https://play.google.com/music/listen)**
    * [Mopidy-SoundClound](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-soundcloud) for **[SoundCloud](https://soundcloud.com/stream)**
    * [Mopidy-YouTube](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-youtube) for **[YouTube](https://www.youtube.com)**
    * AudioAddict (difm)
    * More
  * Frontend extensions:
    * Standards: MPD, HTTP
    * [Mopidy-Scrobbler](http://mopidy.readthedocs.io/en/latest/ext/frontends/#mopidy-scrobbler)
    * [Mopidy-API-Explorer](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-api-explorer)
    * [Mopidy-Local-Images](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-local-images)
    * [Mopidy-Material-Webclient](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-material-webclient)
    * [Mopidy-Mopify](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-mopify)
    * [Mopidy-MusicBox-Webclient](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-musicbox-webclient)
    * [Mopidy-Spotmop](http://mopidy.readthedocs.io/en/latest/ext/web/#mopidy-spotmop)
    * [Mopidy-Moped](https://docs.mopidy.com/en/latest/ext/web/#mopidy-moped)
    * Mopidy-Webhooks
    * Mopidy-Notifier
    * More
  * Runs as `app` user inside the container for security.

You may install additional [backends](https://docs.mopidy.com/en/latest/ext/backends/) or [frontends](https://docs.mopidy.com/en/latest/ext/frontends/).


### Usage

#### PulseAudio over network

First to make [audio from from within a Docker container](http://stackoverflow.com/q/28985714/167897), you should enable [PulseAudio over network](https://wiki.freedesktop.org/www/Software/PulseAudio/Documentation/User/Network/); so if you have X11 you may for example do:

 1. Install [PulseAudio Preferences](http://freedesktop.org/software/pulseaudio/paprefs/). Debian/Ubuntu users can do this:

        $ sudo apt-get install paprefs

 2. Launch `paprefs` (PulseAudio Preferences) > "*Network Server*" tab > Check "*Enable network access to local sound devices*" (you may check "*Don't require authentication*" to avoid mounting cookie file described below).

 3. Restart PulseAudio

        $ sudo service pulseaudio restart

    or

        $ pulseaudio -k
        $ pulseaudio --start

    On some distributions, it may be necessary to completely restart your computer. You can confirm that the settings have successfully been applied running `pax11publish | grep -Eo 'tcp:[^ ]*'`. You should see something like `tcp:myhostname:4713`.

#### General usage

A script is provided to easily start a container using the latest image against your local pulseaudio daemon: [`run`](run).
It's also stored in the image for easy access.

Use it like so, all options are optional, although the more you provide the more functionality you'll have.

```sh
docker run --rm trevorj/mopidy-extras host run \
      -o spotify/username='BLAH' -o spotify/password='BLAH' \
      -o gmusic/username='BLAH' -o gmusic/password='BLAH' \
      -o spotify_web/client_id='BLAH' -o spotify_web/client_secret='BLAH' \
      -o scrobbler/username='BLAH' -o scrobbler/password='BLAH' \
      -o audioaddict/username='BLAH' -o audioaddict/password='BLAH' \
      -o soundcloud/auth_token='BLAH' \
      | bash
```

You can also use `docker-compose` using the provided `docker-compose.yml` file. This works by forwarding your local
PulseAudio configuration into the container as a volume instead of passing in the cookie as an environment variable.

```sh
# in repo
docker-compose run --service-ports mopidy \
      -o spotify/username='BLAH' -o spotify/password='BLAH' \
      -o gmusic/username='BLAH' -o gmusic/password='BLAH' \
      -o spotify_web/client_id='BLAH' -o spotify_web/client_secret='BLAH' \
      -o scrobbler/username='BLAH' -o scrobbler/password='BLAH' \
      -o audioaddict/username='BLAH' -o audioaddict/password='BLAH' \
      -o soundcloud/auth_token='BLAH'
```

See [mopidy's command](https://docs.mopidy.com/en/latest/command/) for possible additional options.

Most elements are optional (see some examples below). Replace `BLAH' accordingly if needed, or disable services (e.g., `-o spotify/enabled=false`):

  * For *Spotify* you'll need a *Premium* account.
  * For *Google Music* use your Google account (if you have *2-Step Authentication*, generate an [app specific password](https://security.google.com/settings/security/apppasswords)).
  * For *SoundCloud*, just [get a token](https://www.mopidy.com/authenticate/) after registering.
  * For *AudioAddict*, you need a premium account if you want to set the quality past 64k, otherwise account is optional.

Ports:

  * 6600 - MPD server (if you use for example ncmpcpp client)
  * 6680 - HTTP server (if you use your browser as client)

Environment variables:

  * `PULSE_SERVER` - PulseAudio server socket.
  * `PULSE_COOKIE_DATA` - Hexadecimal encoded PulseAudio cookie commonly at `~/.config/pulse/cookie`.

Volumes:

  * `/app/Music` (`$XDG_MUSIC_DIR`) - Path to directory with local media files (optional).
  * `/app/.local/share/mopidy` (`$XDG_DATA_HOME/mopidy`) - Path to directory to store local metadata such as libraries and playlists in (optional).

##### Example using HTTP client to stream local files

 1. Give read access to your audio files to user **1000** (`app` ala `$APP_USER`), group **1000** (`app`) or **29** (`audio`), or even all users (e.g., `$ chgrp -R 29 $PWD/media && chmod -R g+r $PWD/media`).

    * Work is currently being done to provide a more dynamic permission allocation.

 2. Index local files:

        $ docker run --rm trevorj/mopidy-extras host run mopidy local scan | bash

 3. Start the server:

```sh
docker run --rm trevorj/mopidy-extras host run \
      -o spotify/username='BLAH' -o spotify/password='BLAH' \
      -o gmusic/username='BLAH' -o gmusic/password='BLAH' \
      -o spotify_web/client_id='BLAH' -o spotify_web/client_secret='BLAH' \
      -o scrobbler/username='BLAH' -o scrobbler/password='BLAH' \
      -o audioaddict/username='BLAH' -o audioaddict/password='BLAH' \
      -o soundcloud/auth_token='BLAH' \
      | bash
```

 4. Browse to http://$HOST:6680/

         $ xdg-open http://$HOST:6680


#### Example using [ncmpcpp](https://docs.mopidy.com/en/latest/clients/mpd/#ncmpcpp) MPD console client

Start the server using the commands above, then run ncmpcpp any usual way, ala:

    $ docker run --rm -it wernight/ncmpcpp ncmpcpp --host "$HOST"


### Feedbacks

Having more issues? [Report a bug on GitHub](https://github.com/wernight/docker-mopidy/issues). Also if you need some additional extensions/plugins that aren't already installed (please explain why).
