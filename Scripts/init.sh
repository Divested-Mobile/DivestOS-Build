#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing, Inc.
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

export DEBLOBBER_REMOVE_AUDIOFX=false; #Set true to remove AudioFX
export DEBLOBBER_REMOVE_IMS=false; #Set true to remove all IMS blobs
export DEBLOBBER_REPLACE_TIME=false; #Set true to replace Qualcomm Time Services with the open source Sony TimeKeep reimplementation
export DEFAULT_DNS_PRESET="OpenNIC"; #Sets default DNS. Options: Cloudflare, OpenNIC, DNSWATCH, Google, OpenDNS, Quad9, Verisign
export GLONASS_FORCED_ENABLE=true; #Enables GLONASS on all devices
export MALWARE_SCAN_ENABLED=true; #Set true to perform a fast scan on patchWorkspace() and a through scan on buildAll()
export MALWARE_SCAN_SETTING="quick"; #buildAll() scan speed. Options: quick, extra, slow, full
export MICROG_INCLUDED=true; #Switch to false to prevent inclusion of microG
export HOSTS_BLOCKING=true; #Switch to false to prevent inclusion of our HOSTS file
export OVERCLOCKS_ENABLED=true; #Switch to false to disable overclocks
export STRONG_ENCRYPTION_ENABLED=false; #Switch to true to enable AES-256bit encryption XXX: THIS WILL **DESTROY** EXISTING INSTALLS!
export NON_COMMERCIAL_USE_PATCHES=false; #Switch to false to prevent inclusion of non-commercial use patches

export REBRAND_NAME="DivestOS";
export REBRAND_ZIP_PREFIX="divested";
export REBRAND_LEGAL="https://divestos.xyz/index.php?page=privacy_policy";
#END OF USER CONFIGURABLE OPTIONS

BUILD_WORKING_DIR=${PWD##*/};
if [ -d ".repo" ]; then
	echo "Detected $BUILD_WORKING_DIR";
else
	echo "Not a valid workspace!";
	return 1;
fi;

export base=$androidWorkspace"Build/$BUILD_WORKING_DIR/";
if [ ! -d "$base" ]; then
	echo "Path mismatch! Please update init.sh!";
	return 1;
fi;

export prebuiltApps=$androidWorkspace"PrebuiltApps/";
export patches=$androidWorkspace"Patches/$BUILD_WORKING_DIR/";
export cvePatchesLinux=$androidWorkspace"Patches/Linux/";
export cvePatchesAndroid=$androidWorkspace"Patches/Android/";
export dosWallpapers=$androidWorkspace"Patches/Wallpapers/";

export scriptsCommon=$androidWorkspace"Scripts/Common/";
export scripts=$androidWorkspace"Scripts/$BUILD_WORKING_DIR/";
if [ ! -d "$scripts" ]; then
	echo "$BUILD_WORKING_DIR is not supported!";
	return 1;
fi;
export cveScripts=$scripts"CVE_Patchers/";

export SIGNING_KEY_DIR=$androidWorkspace"Signing_Keys";
export OTA_PACKAGE_SIGNING_KEY=$SIGNING_KEY_DIR"/releasekey";

export ANDROID_HOME="/home/$USER/Android/Sdk";

export KBUILD_BUILD_USER="emy";
export KBUILD_BUILD_HOST="dosbm";

export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation";
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}";
export GRADLE_OPTS="-Xmx2048m";

source "$scriptsCommon/Functions.sh";
source "$scripts/Functions.sh";

export LC_ALL=C;

unalias cp;
unalias mv;
unalias rm;
unalias ln;
