## About

Have you ever wanted to run an application for Microsoft Windows in a Docker container? I did and that is what you can use this image for.

My motivation for this image was to be able to create windows installer packages (known as MSI). Thus I'm using this image as a base image for [suchja/wix](https://registry.hub.docker.com/u/suchja/wix/). I'm sure that there are lots of other use cases. If you have one, please leave a comment on the [docker hub repository for this image](https://registry.hub.docker.com/u/suchja/wine/).

### Tags

**HINT:** Recently version 1.8 was released, which is a new stable release. So far the most recent development version (1.9.2) is not available from "Wine Team PPA". Thus both images (latest and dev) include the same version (1.8). As soon as a new development version is available this will be used.

This image is provided to you in different versions. You can pull those versions from docker hub by specifying the appropriate tag:

- `suchja/wine:latest` - Provides the latest stable release of Wine (currently 1.6.2) based on a `debian:jessie` base image. Although this is the latest stable release of Wine, it is quite old (around 2 years). Thus not everything will properly work. This image also uses a pretty old version of mono for wine, because the newer versions might not properly function with the old wine version. **Docker images size: around 445MB**
- `suchja/wine:dev`- Provides one of the most recent development releases of Wine (version 1.8 from December 24, 2015). Wine seems to be best supported on Ubuntu. Thus up to date development releases are easily accessible for Ubunut users, but somehow difficult to get for Debian users. Therefore this image is based on `ubuntu:14.04`. **Docker image size: around 740MB**

In case you require any of the latest bug fixes or need a bleeding edge version of wine, you can use `suchja/wine:dev`. Although it is not the latest development version it is quite new. Otherwise you should be fine with `suchja/wine:latest`, which provides the latest stable release.

I'm working on a proper solution to base the stable and the development release on the same Linux distribution. As I'm in favour of `debian:jessie`, I'm trying to get an up to date development release of Wine for it. However, getting signed packages or building Wine from scratch takes some more time for investigation.

### Provided core packages

This image provides the following core packages in addition to the ones contained in the parent image(s):

- [Wine](https://www.winehq.org) - Allows you to run applications developed for Microsoft Windows on a Linux machine
- [winetricks](http://www.winetricks.org) - Tool to install and update some of the important packages for Wine (e.g. .NET Framework)

### Docker image structure

I'm a big fan of the *separation of concerns (SoC)* principle. Therefore I try to create Dockerfiles with mainly one responsibility. Thus it happens that an image is using a base image, which is using another base image, ... Here you see all the base images used for this image:

> [debian:jessie](https://github.com/tianon/docker-brew-debian/blob/188b27233cedf32048ee12378e8f8c6fc0fc0cb4/jessie/Dockerfile) / [ubuntu:14.04](https://github.com/tianon/docker-brew-ubuntu-core/blob/7fef77c821d7f806373c04675358ac6179eaeaf3/trusty/Dockerfile) depending on the chosen Tag.
>>[suchja/x11client](https://registry.hub.docker.com/u/suchja/x11client/dockerfile/) Display any X Window content in a separate container
>>>[suchja/wine](https://registry.hub.docker.com/u/suchja/wine/dockerfile/) This image

## Usage

First of all you should decide for a [Tag](###Tags). In the following examples I'm assuming you go for the stable release, which is `suchja/wine:latest`
.

**ATTENTION:** Please be aware that wine is a multi-process application. Everytime you run the `wine` command, it will start `wineserver` and several other processes, which are not child-processes of `wine`. That means, if you use this image as a base image and use something like `RUN wine your-app.exe` in a dockerfile, this will not work. The reason is that docker assumes wine is completed, once `RUN wine your-app.exe` returns. Unfortunately there are the other process which are still running. When they are killed by docker, this usually results in a corrupt wine prefix. So either use wine only interactively or wait after each call for `wineserver` to be finished. See [suchja/wix](https://registry.hub.docker.com/u/suchja/wix/) image for an example of how to accomplish it.

### Headless (no GUI)

If you don't care about any graphical output from Wine, you can simply start your container like this:

`docker run --rm -it --entrypoint /bin/bash suchja/wine:latest`

Using the `--entrypoint` option instead of providing a command, gives you some information on the command line each time Wine is trying to make some output into a window. Additionally it suppresses the execution of the entrypoint script from base image `suchja/x11client`.

In this case you might also have a look into [wineconsole](http://wine-wiki.org/index.php/Wineconsole) and wine's [console user interface]( https://www.winehq.org/docs/wineusr-guide/cui-programs). I have no experience with them, but will try them out.

### GUI via `suchja/x11server`

If you like to see the graphical output, you first need to run a container based on [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/) like this:

`docker run -d --name display -e VNC_PASSWORD=newPW -p 5900:5900 suchja/x11server`

Now you can start the Wine container like this:

`docker run --rm -it --link display:xserver --volumes-from display suchja/wine:latest /bin/bash`

The `--link display:xserver` and `--volumes-from display` option is only required, if graphical output from Wine shall be shown via [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/). Otherwise these two options can be omitted. Then `wine` will show warning messages, because it is not able to display graphical output.

### Initialize Wine

There is no initialized Wine prefix in the container. Thus your first action in the container should be something like:

`wine wineboot --init`

This will give you warnings indicating that the X server is not running or that $DISPLAY is not defined, if you have not properly linked to a running container of [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/). Obviously this is okay and can be ignored, if Wine is only used to run console applications.

Now your Wine bottle is ready to be tasted.

### Start using Wine

After initializing your Wine prefix you can verify that you are running the expected version:

`wine --version`

The next check is to start Notepad and verify that GUI works:

`wine notepad.exe`

This only works if you have attached an X server. If you like to run a console application, it is now time to add it to the container. You can do this from the command line within the running Wine container, or you bind-mount a volume from your host into the container, which contains the application you like to execute.

For me the above command resulted in seeing Notepad, but without the window title (including the options to close the window). It seems that this can be fixed by telling Wine to emualte a virtual desktop. Therefore the container includes the command `winegui`. This is an alias, which calls `wine` with some additional arguments and can be used like this:

`winegui notpad.exe`

An alternative to using `winegui` is to change the configuration of the "Graphics" via `winecfg` (thanks to dagelf for pointing this out in the comments). This can be accomplished by calling `winecfg`, switching to the "Graphcis" tab and deselecting the following two options:

- Allow the window manager to decorate the windows
- Allow the window manager to control the windows

### Environment variables

Wine does support different environment variables which you can specify when starting a container from this image via `docker run -e VARIABLE_NAME=VALUE` or you set them interactively in the shell inside the started container via `export VARIABLE_NAME=VALUE`.

`WINEDEBUG`

Tells Wine to provide you some additional debug output. This variable is set to `-all`, which means no output at all is provided by Wine. Once the container is started, you can set the environment variable `WINEDEBUG` to another value. For example:

`export WINEDEBUG=+all`

This will tell Wine that it shall output any information, warnings or errors from all components. Please see [this page](http://wiki.winehq.org/DebugChannels) for additional information about Wine debug information.

`WINEDLLOVERRIDES`

Allows you to choose whether nativ DLLs shall be used or those from wine. One of the more frequently used use case is to tell Wine to not use wine-mono. This might be a good idea, if you like to run a native .NET framework version. If you like that, specify the following value:

`export WINEDLLOVERRIDES=mscoree=d`

See [this page](https://www.winehq.org/docs/wineusr-guide/x258) for additional information.

`WINEARCH`

Out of the box Wine is configured to run a 32-bit Windows (`WINEARCH=win32`). You can change this by setting the environment variable `WINEARCH` to nothing **before** you initialize your prefix. Simply type the following command:

`export WINEARCH=''`

Further details about this variable can be found [here](https://wiki.archlinux.org/index.php/Wine#WINEARCH)

`WINEPREFIX`

Wine needs a directory where it stores all windows files and configuration. This is called a prefix. This variable defines where the prefix is located. Wine will automatically create and configure this directory when you execute the first Wine command. The variable is set to `WINEPREFIX=/home/xclient/.wine` in the image. You can create more prefixes and set the variable to that prefix you currently like to use.

## Known problems

### `wine` should not be called in a Dockerfile

See beging of [Usage](##Usage) section.

### X error ... BadValue

While using this image in combination with [suchja/x11server](https://registry.hub.docker.com/u/suchja/x11server/) I experienced the following problems.
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

## Maintenance

I do not have a dedicated maintenance schedule for this image. In case a new stable version of Wine is released, I might update the image accordingly.

If you experience any problems with the image, open up an issue on the [source repository](https://github.com/suchja/wine). I'll look into it as soon as possible.

## Copyright free

The sources in [this](https://github.com/suchja/wine) Github repository, from which the docker image is build, are copyright free (see LICENSE.md). Thus you are allowed to use these sources (e.g. Dockerfile and README.md) in which ever way you like.
