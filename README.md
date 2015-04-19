##About
A Docker Image providing [Wine](https://www.winehq.org) and the latest version of [winetricks](http://www.winetricks.org).

When running a container from this image and linked to a container based on [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/), all graphical output from wine can be seen via VNC client.

**ATTENTION:** This image is pretty large (above 1.1GB).

##Usage
Starting a container from this image can be done as follows:

`docker run --rm -it --link display:xserver --volumes-from display suchja/wine /bin/bash`

The `--link display:xserver` and `--volumes-from display` option is only required, if graphical output from wine shall be shown via [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/). Otherwise these two options can be omitted. Then `wine` will show warning messages, because it is not able to display graphical output.

For the above container to properly run, you must first start the x11server container:

`docker run -d --name display -e VNC_PASSWORD=newPW -p 5900:5900 suchja/x11server`

##Maintenance
Currently there are some warning messages saying that the environment variable `DISPLAY` is not set while building the docker image. Although these messages are annoying, everything seems to work as intended. 

The image is build on Docker hub with [Automated builds](http://docs.docker.com/docker-hub/builds/). Also a [repository link](http://docs.docker.com/docker-hub/builds/#repository-links) to its parent image is configured. So it is automatically updated, when the parent image is updated.

##Copyright free
The sources in [this](https://github.com/suchja/wix-toolset.git) Github repository, from which the docker image is build, are copyright free (see LICENSE.md). Thus you are allowed to use these sources (e.g. Dockerfile and README.md) in which ever way you like.
