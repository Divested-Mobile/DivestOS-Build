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
export base=$androidWorkspace"Build/LineageOS-11.0/";

export patches=$androidWorkspace"Patches/LineageOS-11.0/";
export cvePatches=$androidWorkspace"Patches/Linux_CVEs/";

export scripts=$androidWorkspace"Scripts/LineageOS-11.0/";
export cveScripts=$scripts"CVE_Patchers/";

export ANDROID_HOME="/home/$USER/Android/Sdk";

export KBUILD_BUILD_USER=emy
export KBUILD_BUILD_HOST=dosbm

export GRADLE_OPTS=-Xmx2048m
