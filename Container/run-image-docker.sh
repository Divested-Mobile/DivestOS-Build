#!/usr/bin/env bash
mkdir -p $1
docker run -it --rm -v $1:/home/$(id -un)/DivestOS/Builds -v divestos_ccache:/home/$(id -un)/.ccache android-build-fedora
