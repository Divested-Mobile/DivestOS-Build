#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2021 Divested Computing Group
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

#
#START OF USER CONFIGURABLE OPTIONS
#
#General
export ANDROID_HOME="/home/$USER/Android/Sdk";
export DOS_WORKSPACE_ROOT="/mnt/dos/"; #XXX: THIS MUST BE CORRECT TO BUILD!
#export DOS_BUILDS=$DOS_WORKSPACE_ROOT"Builds/";
export DOS_BUILDS="/mnt/backup-1/DOS/Builds/";
export DOS_SIGNING_KEYS=$DOS_WORKSPACE_ROOT"Signing_Keys/4096pro";
export DOS_SIGNING_GPG=$DOS_WORKSPACE_ROOT"Signing_Keys/gnupg";
#export USE_CCACHE=1;
#export CCACHE_DIR="";
export CCACHE_COMPRESS=1;
export CCACHE_COMPRESSLEVEL=1;
#export DOS_BINARY_PATCHER="";
export DOS_TOR_WRAPPER="";
#export DOS_TOR_WRAPPER="torsocks"; #Uncomment to perform select build operations over Tor
export DOS_MALWARE_SCAN_ENABLED=true; #Set true to perform a fast scan on patchWorkspace() and a through scan on buildAll()
export DOS_MALWARE_SCAN_SETTING="quick"; #buildAll() scan speed. Options: quick, extra, slow, full
export DOS_REFRESH_PATCHES=true; #Set true to refresh branch-specific patches on apply

#Deblobber
export DOS_DEBLOBBER_REMOVE_ACCESSORIES=true; #Set false to allow use of external accessories that depend on blobs
export DOS_DEBLOBBER_REMOVE_ATFWD=true; #Set true to remove basic ATFWD blobs
export DOS_DEBLOBBER_REMOVE_AUDIOFX=true; #Set true to remove AudioFX
export DOS_DEBLOBBER_REMOVE_CNE=true; #Set true to remove all CNE blobs #XXX: Breaks Wi-Fi calling
export DOS_DEBLOBBER_REMOVE_DPM=true; #Set true to remove all DPM blobs
export DOS_DEBLOBBER_REMOVE_DPP=false; #Set true to remove all Display Post Processing blobs #XXX: Breaks boot on select devices
export DOS_DEBLOBBER_REMOVE_FP=false; #Set true to remove all fingerprint reader blobs
export DOS_DEBLOBBER_REMOVE_GRAPHICS=false; #Set true to remove all graphics blobs and use SwiftShader CPU renderer #TODO: Needs work
export DOS_DEBLOBBER_REMOVE_IMS=false; #Set true to remove all IMS blobs XXX: Carriers are phasing out 3G, making IMS mandatory for calls
export DOS_DEBLOBBER_REMOVE_IPA=false; #Set true to remove all IPA blobs
export DOS_DEBLOBBER_REMOVE_IR=false; #Set true to remove all IR blobs
export DOS_DEBLOBBER_REMOVE_RCS=true; #Set true to remove all RCS blobs
export DOS_DEBLOBBER_REMOVE_RENDERSCRIPT=false; #Set true to remove RenderScript blobs
export DOS_DEBLOBBER_REPLACE_TIME=false; #Set true to replace Qualcomm Time Services with the open source Sony TimeKeep reimplementation #TODO: Needs testing

#Features
export DOS_GPS_GLONASS_FORCED=false; #Enables GLONASS on all devices
export DOS_GRAPHENE_MALLOC=true; #Enables use of GrapheneOS' hardened memory allocator on 64-bit platforms on 16.0+17.1
export DOS_GRAPHENE_EXEC=false; #Enables use of GrapheneOS' exec spawning feature on 16.0+17.1 XXX: broken (just on 17.1?)
export DOS_HOSTS_BLOCKING=true; #Set false to prevent inclusion of a HOSTS file
export DOS_HOSTS_BLOCKING_APP="DNS66"; #App installed when built-in blocking is disabled. Options: DNS66
export DOS_HOSTS_BLOCKING_LIST="https://divested.dev/hosts-wildcards"; #Must be in the format "127.0.0.1 bad.domain.tld"
export DOS_LOWRAM_ENABLED=false; #Set true to enable low_ram on all devices
export DOS_MICROG_INCLUDED="NLP"; #Determines inclusion of microG. Options: NLP, FULL
export DOS_NON_COMMERCIAL_USE_PATCHES=false; #Set true to allow inclusion of non-commercial use patches XXX: Unused, see 1dc9247
export DOS_OPTIMIZE_IMAGES=false; #Set true to apply lossless optimizations to image resources
export DOS_STRONG_ENCRYPTION_ENABLED=false; #Set true to enable AES 256-bit FDE encryption on 14.1+15.1 XXX: THIS WILL **DESTROY** EXISTING INSTALLS!
export DOS_WEBVIEW_LFS=true; #Whether to `git lfs pull` in the WebView repository
#alias DOS_WEBVIEW_CHERRYPICK='git pull "https://github.com/LineageOS/android_external_chromium-webview" refs/changes/00/316600/2';

#Servers
export DOS_DEFAULT_DNS_PRESET="Quad9"; #Sets default DNS. Options: See changeDefaultDNS() in Scripts/Common/Functions.sh
export DOS_GPS_NTP_SERVER="2.android.pool.ntp.org"; #Options: Any NTP pool
export DOS_GPS_SUPL_HOST="supl.google.com"; #Options: supl.{google,vodafone,sonyericsson}.com

#Release Processing
export DOS_MALWARE_SCAN_BEFORE_SIGN=false; #Scan device files for malware before signing
export DOS_GENERATE_DELTAS=true; #Creates deltas from existing target_files in $DOS_BUILDS
export DOS_GENERATE_DELTAS_DEVICES=('Amber' 'alioth' 'aura' 'avicii' 'blueline' 'bonito' 'bramble' 'cheryl' 'coral' 'crosshatch' 'davinci' 'enchilada' 'fajita' 'flame' 'FP3' 'guacamole' 'guacamoleb' 'marlin' 'mata' 'pro1' 'redfin' 'sailfish' 'sargo' 'sunfish' 'taimen' 'vayu' 'walleye'); #List of devices deltas will be generated for
export DOS_AUTO_ARCHIVE_BUILDS=true; #Copies files to $DOS_BUILDS after signing
export DOS_REMOVE_AFTER=true; #Removes device OUT directory after complete to reclaim space. Requires AUTO_ARCHIVE_BUILDS=true
export DOS_GPG_SIGNING=true;
export DOS_GPG_SIGNING_KEY="B8744D67F9F1E14E145DFD8E7F627E920F316994";

#Branding
export DOS_BRANDING_NAME="DivestOS";
export DOS_BRANDING_ZIP_PREFIX="divested";
export DOS_BRANDING_BOOTANIMATION_FONT="Fira-Sans-Heavy"; #Options: $ convert -list font
export DOS_BRANDING_BOOTANIMATION_STYLE="plasma"; #Options: gradient, plasma
#export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#FF8A65"; #gradient
export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#03A9F4"; #plasma
export DOS_BRANDING_LINK_ABOUT="https://divestos.org/index.php?page=about";
export DOS_BRANDING_LINK_PRIVACY="https://divestos.org/index.php?page=privacy_policy";
export DOS_BRANDING_SERVER_OTA="https://divestos.org/updater.php";
export DOS_BRANDING_SERVER_OTA_ONION=$DOS_BRANDING_SERVER_OTA; #TODO: need to handle allow cleartext

#Theme
export DOS_THEME_50="FFCA28"; #Amber 400
export DOS_THEME_100="FFC107"; #Amber 500
export DOS_THEME_200="FFA726"; #Orange 400
export DOS_THEME_300="FF9800"; #Orange 500
export DOS_THEME_500="FF5722"; #Deep Orange 500
export DOS_THEME_700="E64A19"; #Deep Orange 700
#
#END OF USER CONFIGURABLE OPTIONS
#

umask 0022;

gpgVerifyGitHead() {
	if [ -r "$HOME/.gnupg" ]; then
		if git -C $1 verify-commit HEAD; then
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
DOS_VERSION=$BUILD_WORKING_DIR;
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
mkdir -p "$DOS_TMP_DIR";
export DOS_HOSTS_FILE="$DOS_TMP_DIR/hosts";

export DOS_PREBUILT_APPS=$DOS_WORKSPACE_ROOT"PrebuiltApps/";
export DOS_PATCHES_COMMON=$DOS_WORKSPACE_ROOT"Patches/Common/";
export DOS_PATCHES=$DOS_WORKSPACE_ROOT"Patches/$BUILD_WORKING_DIR/";
export DOS_PATCHES_LINUX_CVES=$DOS_WORKSPACE_ROOT"Patches/Linux/";
export DOS_WALLPAPERS=$DOS_WORKSPACE_ROOT"Patches/Wallpapers/";

export DOS_SCRIPTS_COMMON=$DOS_WORKSPACE_ROOT"Scripts/Common/";
export DOS_SCRIPTS=$DOS_WORKSPACE_ROOT"Scripts/$BUILD_WORKING_DIR/";
if [ ! -d "$DOS_SCRIPTS" ]; then
	echo "$BUILD_WORKING_DIR is not supported!";
	return 1;
fi;
export DOS_SCRIPTS_CVES=$DOS_SCRIPTS"CVE_Patchers/";

export KBUILD_BUILD_USER="emy";
export KBUILD_BUILD_HOST="dosbm";
export BUILD_USERNAME="emy";
export BUILD_HOSTNAME="dosbm";

export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation";
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}";
export EXPERIMENTAL_USE_JAVA8=true;
export GRADLE_OPTS="-Xmx2048m";
export TZ=:/etc/localtime;
export LC_ALL=C;
export LANG=en_US.UTF-8;

#START OF VERIFICATION
#gpgVerifyGitHead $DOS_WORKSPACE_ROOT;
#gpgVerifyGitHead $DOS_PREBUILT_APPS;
#gpgVerifyGitHead $DOS_PATCHES_LINUX_CVES;
#gpgVerifyGitHead $DOS_WALLPAPERS;
#END OF VERIFICATION

source "$DOS_SCRIPTS_COMMON/Shell.sh";
source "$DOS_SCRIPTS_COMMON/Functions.sh";
source "$DOS_SCRIPTS/Functions.sh";
