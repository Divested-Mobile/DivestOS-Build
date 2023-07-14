#!/bin/bash
mkdir -p $1 $2
podman run -it --rm --user=$(id -un) --workdir="/home/$(id -un)" --entrypoint="/bin/bash" -v $1:/home/$(id -un)/android -v $2:/home/$(id -un)/.ccache android-build-fedora
