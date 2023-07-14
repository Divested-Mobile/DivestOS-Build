#!/bin/bash

# from https://android.googlesource.com/platform/build/+/master/tools/docker
# Copy your host gitconfig, or create a stripped down version
cp ~/.gitconfig gitconfig
podman build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) --build-arg username=$(id -un) -t android-build-fedora .
rm gitconfig
