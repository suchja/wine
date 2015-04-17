##About
A Docker Image running [Wine](https://www.winehq.org) and [WiX](http://wixtoolset.org) for creating windows installer packages (msi).

**ATTENTION:** This image is pretty large (above 1.2GB).

##Usage

##Maintenance
Currently there are some warning messages saying that the environment variable `DISPLAY` is not set while building the docker image. Although these messages are annoying, everything seems to work as intended. 

The image is build on Docker hub with [Automated builds](http://docs.docker.com/docker-hub/builds/). Also a [repository link](http://docs.docker.com/docker-hub/builds/#repository-links) to its parent image is configured. So it is automatically updated, when the parent image is updated.

**Latest wix binaries:** Unfortunately the latest released wix-binaries cannot be downloaded programmatically. Problem seems to be some wired behaviour of codeplex. Thus a proper download link for the latest released wix binaries needs to be searched manually.

**Startup time vs. disk space:** The pretty large image size is mainly due to the space required by wine. Without booting wine (`wine wineboot`) this image would be less than half the size. Unfortunately booting up wine is required to install some windows components. As I do favour startup time over disk space, I decided to 

##Copyright free
The sources in [this](https://github.com/suchja/wix-toolset.git) Github repository, from which the docker image is build, are copyright free (see LICENSE.md). Thus you are allowed to use these sources (e.g. Dockerfile and README.md) in which ever way you like.
