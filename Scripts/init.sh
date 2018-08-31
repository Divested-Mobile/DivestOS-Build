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
export DOS_WORKSPACE_ROOT="/mnt/Drive-3/"; #XXX: THIS MUST BE CORRECT TO BUILD!
export DOS_SIGNING_KEYS=$DOS_WORKSPACE_ROOT"Signing_Keys";
#export DOS_BINARY_PATCHER="";

export DOS_DEBLOBBER_REMOVE_ACCESSORIES=true; #Set false to allow use of external accessories
export DOS_DEBLOBBER_REMOVE_AUDIOFX=true; #Set true to remove AudioFX
export DOS_DEBLOBBER_REMOVE_GRAPHICS=false; #Set true to remove all graphics blobs and use SwiftShader CPU renderer
export DOS_DEBLOBBER_REMOVE_FP=false; #Set true to remove all fingerprint reader blobs
export DOS_DEBLOBBER_REMOVE_IMS=false; #Set true to remove all IMS blobs
export DOS_DEBLOBBER_REMOVE_IPA=false; #Set true to remove all IPA blobs
export DOS_DEBLOBBER_REMOVE_IR=false; #Set true to remove all IR blobs
export DOS_DEBLOBBER_REPLACE_TIME=false; #Set true to replace Qualcomm Time Services with the open source Sony TimeKeep reimplementation #TODO: Needs work
export DOS_DEFAULT_DNS_PRESET="Cloudflare"; #Sets default DNS. Options: Cloudflare, OpenNIC, DNSWATCH, Google, OpenDNS, Quad9, Quad9U, Verisign
export DOS_GPS_SUPL_HOST="supl.google.com"; #Options: supl.{google,vodafone,sonyericsson}.com
export DOS_GPS_NTP_SERVER="time.android.com"; #Options: Any NTP pool
export DOS_GPS_GLONASS_FORCED=true; #Enables GLONASS on all devices
export DOS_MALWARE_SCAN_ENABLED=true; #Set true to perform a fast scan on patchWorkspace() and a through scan on buildAll()
export DOS_MALWARE_SCAN_SETTING="quick"; #buildAll() scan speed. Options: quick, extra, slow, full
export DOS_MICROG_INCLUDED="NLP"; #Determines inclusion of microG. Options: NLP, FULL
export DOS_HOSTS_BLOCKING=true; #Switch to false to prevent inclusion of our HOSTS file
export DOS_HOSTS_BLOCKING_LIST="https://divestos.xyz/hosts"; #Must be in the format "127.0.0.1 bad.domain.tld"
export DOS_OVERCLOCKS_ENABLED=true; #Switch to false to disable overclocks #XXX: Most devices have their processors directly under their RAM, heatsinking is mostly into the ground plane, potentially inflicting damage to RAM and the processor itself
export DOS_LOWRAM_ENABLED=false; #Switch to true to enable low_ram on all devices
export DOS_STRONG_ENCRYPTION_ENABLED=false; #Switch to true to enable AES-256bit encryption XXX: THIS WILL **DESTROY** EXISTING INSTALLS!
export DOS_NON_COMMERCIAL_USE_PATCHES=false; #Switch to false to prevent inclusion of non-commercial use patches

export DOS_BRANDING_NAME="DivestOS";
export DOS_BRANDING_ZIP_PREFIX="divested";
export DOS_BRANDING_BOOTANIMATION_FONT="Fira-Sans-Bold"; #Options: $ convert -list font
export DOS_BRANDING_BOOTANIMATION_STYLE="plasma"; #Options: gradient, plasma
#export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#FF8A65"; #gradient
export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#03A9F4"; #plasma
export DOS_BRANDING_LINK_ABOUT="https://divestos.xyz/index.php?page=about";
export DOS_BRANDING_LINK_PRIVACY="https://divestos.xyz/index.php?page=privacy_policy";
export DOS_BRANDING_SERVER_OTA="https://divestos.xyz/updater.php";

export DOS_THEME_50="FFCA28"; #Amber 400
export DOS_THEME_100="FFC107"; #Amber 500
export DOS_THEME_200="FFA726"; #Orange 400
export DOS_THEME_300="FF9800"; #Orange 500
export DOS_THEME_500="FF5722"; #Deep Orange 500
export DOS_THEME_700="E64A19"; #Deep Orange 700

#export USE_CCACHE=1;
#export CCACHE_DIR="";
export ANDROID_HOME="/home/$USER/Android/Sdk";
#END OF USER CONFIGURABLE OPTIONS

gpgVerifyGitHead() {
	if [ -r "$HOME/.gnupg" ]; then
		git -C $1 verify-commit HEAD;
		if [ "$?" -eq "0" ]; then
			echo -e "\e[0;32mGPG Verified Git HEAD Successfully: $1\e[0m";
		else
			echo -e "\e[0;31mWARNING: GPG Verification of Git HEAD Failed: $1\e[0m";
			sleep 60;
		fi;
		#git -C $1 log --show-signature -1;
	else
		echo -e "\e[0;33mWARNING: ~/.gnupg is unavailable, GPG verification of $1 will not be performed!\e[0m";
	fi;
}
export -f gpgVerifyGitHead;

BUILD_WORKING_DIR=${PWD##*/};
if [ -d ".repo" ]; then
	echo "Detected $BUILD_WORKING_DIR";
else
	echo "Not a valid workspace!";
	return 1;
fi;

export DOS_BUILD_BASE=$DOS_WORKSPACE_ROOT"Build/$BUILD_WORKING_DIR/";
if [ ! -d "$DOS_BUILD_BASE" ]; then
	echo "Path mismatch! Please update init.sh!";
	return 1;
fi;

export DOS_TMP_DIR="/tmp/dos_tmp";
mkdir "$DOS_TMP_DIR";
export DOS_HOSTS_FILE="$DOS_TMP_DIR/hosts";

export DOS_PREBUILT_APPS=$DOS_WORKSPACE_ROOT"PrebuiltApps/";
export DOS_PATCHES_COMMON=$DOS_WORKSPACE_ROOT"Patches/Common/";
export DOS_PATCHES=$DOS_WORKSPACE_ROOT"Patches/$BUILD_WORKING_DIR/";
export DOS_PATCHES_OVERCLOCKS=$DOS_WORKSPACE_ROOT"Patches/Overclocks/";
export DOS_PATCHES_LINUX_CVES=$DOS_WORKSPACE_ROOT"Patches/Linux/";
export DOS_WALLPAPERS=$DOS_WORKSPACE_ROOT"Patches/Wallpapers/";

export DOS_SCRIPTS_COMMON=$DOS_WORKSPACE_ROOT"Scripts/Common/";
export DOS_SCRIPTS=$DOS_WORKSPACE_ROOT"Scripts/$BUILD_WORKING_DIR/";
if [ ! -d "$DOS_SCRIPTS" ]; then
	echo "$BUILD_WORKING_DIR is not supported!";
	return 1;
fi;
export DOS_SCRIPTS_CVES=$DOS_SCRIPTS"CVE_Patchers/";

export SIGNING_KEY_DIR=$DOS_SIGNING_KEYS;
export OTA_PACKAGE_SIGNING_KEY=$SIGNING_KEY_DIR"/releasekey";

export KBUILD_BUILD_USER="emy";
export KBUILD_BUILD_HOST="dosbm";

export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation";
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}";
export GRADLE_OPTS="-Xmx2048m";
export LC_ALL=C;
#alias patch='patch --no-backup-if-mismatch';

#START OF VERIFICATION
#gpgVerifyGitHead $DOS_WORKSPACE_ROOT;
#gpgVerifyGitHead $DOS_PREBUILT_APPS;
#gpgVerifyGitHead $DOS_PATCHES_LINUX_CVES;
#gpgVerifyGitHead $DOS_WALLPAPERS;
#END OF VERIFICATION

source "$DOS_SCRIPTS_COMMON/Functions.sh";
source "$DOS_SCRIPTS/Functions.sh";

unalias cp &>/dev/null || true;
unalias mv &>/dev/null || true;
unalias rm &>/dev/null || true;
unalias ln &>/dev/null || true;
