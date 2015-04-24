##About
Have you ever wanted to run an application for Microsoft Windows in a Docker container? I did and that is what you can use this image for.

My motivation for this image was to be able to create windows installer packages (known as MSI). Thus I'm using this image as a base image for [suchja/wix](https://registry.hub.docker.com/u/suchja/wix/). I'm sure that there are lots of other use cases. If you have one, please leave a comment on the [docker hub repository for this image](https://registry.hub.docker.com/u/suchja/wine/).

###Tags
This image is provided to you in different versions. You can pull those versions from docker hub by specifying the appropriate tag:

- `suchja/wine:latest` - Provides the latest stable release of Wine (currently 1.6.2) based on a `debian:jessie` base image. Although this is the latest stable release of Wine, it is quite old (around 2 years). Thus not everything will properly work. **Docker images size: around 480MB**
- `suchja/wine:dev1.7.38` - Provides one of the most recent development releases of Wine (version 1.7.38 from March 6, 2015). Wine seems to be best supported on Ubuntu. Thus up to date development releases are easily accessible for Ubunut users, but somehow difficult to get for Debian users. Therefore this image is based on `ubuntu:14.04`. **Docker image size: around 850MB**

As long as you have an application, which does not require a specific .NET framework version or you are doing other fancy things, you probably will be satisfied by `suchja/wine:latest`.

I tried installing .NET 4.0 framework from Microsoft on `suchja/wine:latest` without any success. That's the reason why there is `suchja/wine:dev1.7.38`
. So if you like to be on the bleeding edge of Wine or need for example a recent version of the .NET framework from Microsoft, this is the version for you.

I'm working on a proper solution to base the stable and the development release on the same linux distribution. As I'm in favour of `debian:jessie`, I'm trying to get an up to date development release of Wine for it. However, getting signed packages or building Wine from scratch takes some more time for investigation.

###Provided core packages
This image provides the following core packages in addition to the ones contained in the parent image(s):

- [Wine](https://www.winehq.org) - Allows you to run applications developed for Microsoft Windows on a Linux machine
- [winetricks](http://www.winetricks.org) - Tool to install and update some of the important packages for Wine (e.g. .NET Framework)

###Docker image structure
I'm a big fan of the *separation of concerns (SoC)* principle. Therefore I try to create Dockerfiles with mainly one responsibility. Thus it happens that an image is using a base image, which is using another base image, ... Here you see all the base images used for this image:

> [debian:jessie](https://github.com/tianon/docker-brew-debian/blob/188b27233cedf32048ee12378e8f8c6fc0fc0cb4/jessie/Dockerfile) / [ubuntu:14.04](https://github.com/tianon/docker-brew-ubuntu-core/blob/7fef77c821d7f806373c04675358ac6179eaeaf3/trusty/Dockerfile) depending on the chosen Tag.
>>[suchja/x11client](https://registry.hub.docker.com/u/suchja/x11client/dockerfile/) Display any X Window content in a separate container ([suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/))
>>>[suchja/wine](https://registry.hub.docker.com/u/suchja/wine/dockerfile/) This image

##Usage
First of all you should decide for a [Tag](###Tags). In the following examples I'm assuming you go for the stable release, which is `suchja/wine:latest`
.

Independently of how you start the Wine (see below), you can tell Wine to provide you some additional debug output. Once the container is started, you can set the environment variable `WINEDEBUG` to another value. For example:

`export WINEDEBUG=+all`

This will tell Wine that it shall output any information, warnings or errors from all components. Please see [this page](http://wiki.winehq.org/DebugChannels) for additional information about Wine debug information.

###Headless (no GUI)
If you don't care about any graphical output from Wine, you can simply start your container like this:

`docker run --rm -it --entrypoint /bin/bash suchja/wine:latest`

Using the `--entrypoint` option instead of providing a command, gives you some information on the command line each time Wine is trying to make some output into a window. Additionally it suppresses the execution of the entrypoint script from base image `suchja/x11client`.

###GUI via `suchja/x11server`
If you like to see the graphical output, you first need to run a container based on [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/):
Starting a container from this image can be done as follows:

`docker run -d --name display -e VNC_PASSWORD=newPW -p 5900:5900 suchja/x11server`

Now you can start the Wine container like this:

`docker run --rm -it --link display:xserver --volumes-from display suchja/wine:latest /bin/bash`

The `--link display:xserver` and `--volumes-from display` option is only required, if graphical output from Wine shall be shown via [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/). Otherwise these two options can be omitted. Then `wine` will show warning messages, because it is not able to display graphical output.

###Initialize Wine
There is no initialized Wine prefix in the container. Thus your first action in the container should be something like:

`wine wineboot --update`

This will give you warnings indicating that the X server is not running or that $DISPLAY is not defined, if you have not properly linked to a running container of [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/). Obviously this is okay and can be ignored, if Wine is only used to run console applications.

I haven't investigated it fully, but it seems that `wine wineboot --update` is better for creating the prefix than `wine wineboot --init`. During update wine-mono as well as wine-gecko is properly installed into the prefix. This seems not to be true for init. 

Out of the box Wine is configured to run a 32-bit Windows (`WINEARCH=win32`). You can change this by setting the environment variable `WINEARCH` to nothing **before** you initialize your prefix. Simply type the following command:

`export WINEARCH=''`

Now your Wine bottle is ready to be tasted.

###Start using Wine
After initializing your Wine prefix you can verify that it is properly running by starting Notepad:

`wine notepad.exe`

This only works if you have attached an X server. If you like to run a console application, it is now time to add it to the container. You can do this from the command line within the running Wine container, or you bind-mount a volume from your host into the container, which contains the application you like to execute.

For me the above command resulted in seeing Notepad, but without the window title (including the options to close the window). It seems that this can be fixed by telling Wine to emualte a virtual desktop. Therefore the container includes the command `winegui`. This is an alias, which calls `wine` with some additional arguments and can be used like this:

`winegui notpad.exe`

##Known problems
While using this image in combination with [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/) I experienced the following problems.

###X error ... BadValue
From time to time I have seen the following error message after executing a Wine command (mostly after the first `wine wineboot --init`):

```
X Error of failed request:  BadValue (integer parameter out of range for operation)
  Major opcode of failed request:  130 (MIT-SHM)
  Minor opcode of failed request:  3 (X_ShmPutImage)
  Value in failed request:  0x140
  Serial number of failed request:  213
  Current serial number in output stream:  219
```

I haven't figured out the exact reason for it, but it seems that it is somehow related to the remote X server. As far as I can tell it does not have any impact, but maybe somebody with more knowledge about X Window and/or Wine can point me into the right direction.

##Maintenance
I do not have a dedicated maintenance schedule for this image. In case a new stable version of Wine is released, I might update the image accordingly.

If you experience any problems with the image, open up an issue on the [source repository](https://github.com/suchja/wine). I'll look into it as soon as possible.

##Copyright free
The sources in [this](https://github.com/suchja/wine) Github repository, from which the docker image is build, are copyright free (see LICENSE.md). Thus you are allowed to use these sources (e.g. Dockerfile and README.md) in which ever way you like.
