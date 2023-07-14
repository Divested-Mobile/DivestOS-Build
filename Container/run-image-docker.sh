#!/bin/bash
mkdir -p $1 $2
docker run -it --rm -v $1:/home/$(id -un)/android -v $2:/home/$(id -un)/.ccache android-build-fedora
