FROM suchja/x11client:latest
MAINTAINER Jan Suchotzki <jan@suchotzki.de>

# Inspired by monokrome/wine

USER root

# winetricks is located in the contrib repository
RUN echo "deb http://http.debian.net/debian jessie contrib" > /etc/apt/sources.list.d/contrib.list

# Install wine and related packages
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends \
				unzip \
				msttcorefonts \
				wine \
				wine32 \
		&& rm -rf /var/lib/apt/lists/*

# Use the latest version of winetricks
RUN curl -SL 'http://winetricks.org/winetricks' -o /usr/local/bin/winetricks \
		&& chmod +x /usr/local/bin/winetricks

# Wine really doesn't like to be run as root, so let's use a non-root user
USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine
ENV WINEARCH win32

# Install .NET Framework 4.0
WORKDIR /home/xclient
RUN wine wineboot && winetricks --unattended dotnet40
