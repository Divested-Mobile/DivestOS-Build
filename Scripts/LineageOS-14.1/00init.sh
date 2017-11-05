#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017 Spot Communications, Inc.
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
