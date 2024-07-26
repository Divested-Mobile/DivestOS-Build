#!/usr/bin/env bash
mkdir -p $1
podman run -it --rm --user=$(id -un) --workdir="/home/$(id -un)" --entrypoint="/bin/bash" -v $1:/home/$(id -un)/android -v divestos_ccache:/home/$(id -un)/.ccache android-build-fedora
