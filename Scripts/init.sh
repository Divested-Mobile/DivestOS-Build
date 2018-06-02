#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Spot Communications, Inc.
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

#START OF USER CONFIGURABLE OPTIONS
export androidWorkspace="/mnt/Drive-3/"; #XXX: THIS MUST BE CORRECT TO BUILD!


export DEFAULT_DNS="OpenNIC"; #Sets default DNS, choices: Cloudflare, OpenNIC
export MALWARE_SCAN_ENABLED=true; #Set true to perform a fast scan on patchWorkspace() and a through scan on buildAll()
export MALWARE_SCAN_SETTING="quick"; #buildAll() scan speed. Options are quick, extra, slow, full
export MICROG_INCLUDED=true; #Switch to false to prevent inclusion of microG
export HOSTS_BLOCKING=true; #Switch to false to prevent inclusion of our HOSTS file
export NON_COMMERCIAL_USE_PATCHES=false; #Switch to false to prevent inclusion of non-commercial use patches
#END OF USER CONFIGURABLE OPTIONS

BUILD_WORKING_DIR=${PWD##*/};

export SIGNING_KEY_DIR=$androidWorkspace"Signing_Keys";
export OTA_PACKAGE_SIGNING_KEY=$SIGNING_KEY_DIR"/releasekey";

export base=$androidWorkspace"Build/$BUILD_WORKING_DIR/";

export prebuiltApps=$androidWorkspace"PrebuiltApps/";
export patches=$androidWorkspace"Patches/$BUILD_WORKING_DIR/";
export cvePatchesLinux=$androidWorkspace"Patches/Linux/";
export cvePatchesAndroid=$androidWorkspace"Patches/Android/";
export dosWallpapers=$androidWorkspace"Patches/Wallpapers/";

export scriptsCommon=$androidWorkspace"Scripts/Common/";
export scripts=$androidWorkspace"Scripts/$BUILD_WORKING_DIR/";
export cveScripts=$scripts"CVE_Patchers/";

export ANDROID_HOME="/home/$USER/Android/Sdk";

export KBUILD_BUILD_USER="emy";
export KBUILD_BUILD_HOST="dosbm";

export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation";
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}";
export GRADLE_OPTS="-Xmx2048m";

source $scriptsCommon"/Functions.sh";
source $scripts"/Functions.sh";

export LC_ALL=C;

unalias cp;
unalias mv;
unalias rm;
unalias ln;
