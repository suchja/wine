FROM suchja/x11client:ubuntu
MAINTAINER Jan Suchotzki <jan@suchotzki.de>

USER root

# Define which versions we need
ENV WINE_PPA_VERSION 1:1.7.38-0ubuntu1
ENV WINE_MONO_VERSION 4.5.6
ENV WINE_GECKO_VERSION 2.36

# Install packages for building the image
RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends \
		curl \
		unzip \
		software-properties-common \
	&& add-apt-repository ppa:ubuntu-wine/ppa

# Install wine and related packages
RUN dpkg --add-architecture i386 \
	&& apt-get update -y \
	&& apt-get install -y --no-install-recommends \
		wine1.7=$WINE_PPA_VERSION \
		wine-gecko$WINE_GECKO_VERSION:i386 \
		wine-gecko$WINE_GECKO_VERSION:amd64 \
		wine-mono$WINE_MONO_VERSION \
	&& rm -rf /var/lib/apt/lists/*

# Use latest version of winetricks from github
RUN curl -SL 'http://winetricks.org/winetricks' -o /usr/local/bin/winetricks \
	&& chmod +x /usr/local/bin/winetricks

# Wine really doesn't like to be run as root, so let's use a non-root user
USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine

# Tell wine to behave like a 32-bit Windows.
# https://wiki.archlinux.org/index.php/Wine#WINEARCH
ENV WINEARCH win32

# We have a development build of wine, which means tons of debug output.
# Thus we should suppress it: https://www.winehq.org/docs/winedev-guide/dbg-control
ENV WINEDEBUG -all

# Use xclient's home dir as working dir
WORKDIR /home/xclient

RUN echo "alias winegui='wine explorer /desktop=DockerDesktop,1024x768'" > ~/.bash_aliases 
