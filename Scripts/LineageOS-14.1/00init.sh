#!/bin/bash
#Copyright (c) 2017 Spot Communications, Inc.

#Sets settings used by all other scripts

export androidWorkspace="/mnt/Drive-1/Development/Other/Android_ROMs/";
export base=$androidWorkspace"Build/LineageOS-14.1/";

export patches=$androidWorkspace"Patches/LineageOS-14.1/";
export cvePatches=$androidWorkspace"Patches/Linux_CVEs/";
export dosWallpapers=$androidWorkspace"Patches/DivestOS_Wallpapers/";

export scripts=$androidWorkspace"Scripts/LineageOS-14.1/";
export cveScripts=$scripts"CVE_Patchers/";

export ANDROID_HOME="/home/$USER/Android/Sdk";

export KBUILD_BUILD_USER=emy
export KBUILD_BUILD_HOST=dosbm

export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation"
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}"

export GRADLE_OPTS=-Xmx2048m
