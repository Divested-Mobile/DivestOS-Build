#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2017-2024 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#Sets settings used by all other scripts

#
#START OF USER CONFIGURABLE OPTIONS
#
#General
export DOS_WORKSPACE_ROOT="/mnt/dos/"; #XXX: THIS MUST BE CORRECT TO BUILD!
#export DOS_BUILDS=$DOS_WORKSPACE_ROOT"Builds/";
export DOS_BUILDS="/mnt/Storage-1/DivestOS/Builds/"; #XXX: THIS MUST BE CORRECT TO BUILD!
export DOS_SIGNING_KEYS="$DOS_WORKSPACE_ROOT/Signing_Keys/4096pro";
export DOS_SIGNING_GPG="$DOS_WORKSPACE_ROOT/Signing_Keys/gnupg";
#export USE_CCACHE=1;
#export CCACHE_DIR="";
export CCACHE_COMPRESS=1;
export CCACHE_COMPRESSLEVEL=1;
#export DOS_BINARY_PATCHER="";
export DOS_MALWARE_SCAN_ENABLED=false; #Set true to perform a fast scan on patchWorkspace() and a through scan on buildAll()
export DOS_MALWARE_SCAN_SETTING="quick"; #buildAll() scan speed. Options: quick, extra, slow, full
export DOS_REFRESH_PATCHES=true; #Set true to refresh branch-specific patches on apply

#Deblobber
export DOS_DEBLOBBER_REMOVE_ACCESSORIES=true; #Set false to allow use of external accessories that depend on blobs
export DOS_DEBLOBBER_REMOVE_ATFWD=true; #Set true to remove basic ATFWD blobs
export DOS_DEBLOBBER_REMOVE_AUDIOFX=true; #Set true to remove AudioFX
export DOS_DEBLOBBER_REMOVE_APTX=false; #Set true to remove aptX Bluetooth codec
export DOS_DEBLOBBER_REMOVE_CNE=true; #Set true to remove all CNE blobs #XXX: Breaks Wi-Fi calling
export DOS_DEBLOBBER_REMOVE_DPM=true; #Set true to remove all DPM blobs #XXX: Maybe breaks multi-sim and carrier aggregation (LTE+)
export DOS_DEBLOBBER_REMOVE_DPP=false; #Set true to remove all Display Post Processing blobs #XXX: Breaks boot on select devices
export DOS_DEBLOBBER_REMOVE_FACE=false; #Set true to remove all face unlock blobs
export DOS_DEBLOBBER_REMOVE_FP=false; #Set true to remove all fingerprint reader blobs
export DOS_DEBLOBBER_REMOVE_EUICC=true; #Set true to remove all Google eUICC blobs
export DOS_DEBLOBBER_REMOVE_EUICC_FULL=false; #Set true to remove all hardware eUICC blobs
export DOS_DEBLOBBER_REMOVE_IMS=false; #Set true to remove all IMS blobs #XXX: Carriers are phasing out 3G, making IMS mandatory for calls
export DOS_DEBLOBBER_REMOVE_IPA=false; #Set true to remove all IPA blobs
export DOS_DEBLOBBER_REMOVE_IR=false; #Set true to remove all IR blobs
export DOS_DEBLOBBER_REMOVE_RCS=true; #Set true to remove all RCS blobs

#Features
export DOS_HOSTS_BLOCKING=true; #Set false to prevent inclusion of a HOSTS file
export DOS_HOSTS_BLOCKING_LIST="https://divested.dev/hosts-wildcards"; #Must be in the format "127.0.0.1 bad.domain.tld"
export DOS_SENSORS_PERM=false; #Set true to provide a per-app sensors permission for 14.1/15.1 #XXX: can break things like camera
export DOS_USE_KSM=false; #Set true to use KSM for increased memory efficiency at the cost of easier side-channel attacks and increased CPU usage #XXX: testing only

#Servers
export DOS_DEFAULT_DNS_PRESET="Quad9"; #Sets default DNS. Options: See changeDefaultDNS() in Scripts/Common/Functions.sh
export DOS_GPS_NTP_SERVER="2.android.pool.ntp.org"; #Options: Any NTP pool
export DOS_GPS_SUPL_HOST="supl.google.com"; #Options: Any *valid* SUPL server

#Release Processing
export DOS_MALWARE_SCAN_BEFORE_SIGN=false; #Scan device files for malware before signing
export DOS_GENERATE_DELTAS=false; #Creates deltas from existing target_files in $DOS_BUILDS
export DOS_AUTO_ARCHIVE_BUILDS=true; #Copies files to $DOS_BUILDS after signing
export DOS_REMOVE_AFTER=true; #Removes device OUT directory after complete to reclaim space. Requires AUTO_ARCHIVE_BUILDS=true
export DOS_REMOVE_AFTER_FULL=false; #Removes the entire OUT directory
export DOS_GPG_SIGNING=true;
export DOS_GPG_SIGNING_KEY="B8744D67F9F1E14E145DFD8E7F627E920F316994";

#Branding
export DOS_BRANDING_ORG="Divested Computing Group";
export DOS_BRANDING_NAME="DivestOS";
export DOS_BRANDING_EMAIL="support@divestos.org";
export DOS_BRANDING_ZIP_PREFIX="divested";
export DOS_BRANDING_BOOTANIMATION_FONT="Fira-Sans-Heavy"; #Options: $ convert -list font
export DOS_BRANDING_BOOTANIMATION_STYLE="plasma"; #Options: gradient, plasma
#export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#FF8A65"; #gradient
export DOS_BRANDING_BOOTANIMATION_COLOR="#FF5722-#03A9F4"; #plasma
export DOS_BRANDING_LINK_ABOUT="https://divestos.org/pages/about";
export DOS_BRANDING_LINK_NEWS="https://divestos.org/pages/news";
export DOS_BRANDING_LINK_PRIVACY="https://divestos.org/pages/privacy_policy";

#OTAs
export DOS_OTA_SERVER_PRIMARY="https://divestos.org/updater.php";
export DOS_OTA_SERVER_EXTENDED=true; #Enable to provide multiple choices as set below
export DOS_OTA_SERVER_SECONDARY="https://divestos.eeyo.re/updater.php";
export DOS_OTA_SERVER_SECONDARY_NAME="Cloudflare";
export DOS_OTA_SERVER_ONION_PRIMARY="http://divestoseb5nncsydt7zzf5hrfg44md4bxqjs5ifcv4t7gt7u6ohjyyd.onion/updater.php";
export DOS_OTA_SERVER_ONION_SECONDARY="http://2ceyag7ppvhliszes2v25n5lmpwhzqrc7sv72apqka6hwggfi42y2uid.onion/updater.php";
export DOS_OTA_SERVER_ONION_DOMAIN_PRIMARY="divestoseb5nncsydt7zzf5hrfg44md4bxqjs5ifcv4t7gt7u6ohjyyd.onion"; #Used for network security config
export DOS_OTA_SERVER_ONION_DOMAIN_SECONDARY="2ceyag7ppvhliszes2v25n5lmpwhzqrc7sv72apqka6hwggfi42y2uid.onion";

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
[ -f "$HOME/.divested.vars" ] && source $HOME/.divested.vars && echo "included $HOME/.divested.vars config"
[ -f "$HOME/.divested.vars.${BDEVICE}" ] && source $HOME/.divested.vars.${BDEVICE} && echo "included $HOME/.divested.vars.${BDEVICE} config"

umask 0022;

gpgVerifyGitHead() {
	if [ -r "$DOS_TMP_GNUPG/pubring.kbx" ]; then
		if git -C "$1" verify-commit HEAD &>/dev/null; then
			echo -e "\e[0;32mGPG Verified Git HEAD Successfully: $1\e[0m";
		else
			echo -e "\e[0;31mWARNING: GPG Verification of Git HEAD Failed: $1\e[0m";
			#sleep 60;
		fi;
		#git -C $1 log --show-signature -1;
	else
		echo -e "\e[0;33mWARNING: keyring is unavailable, GPG verification of $1 will not be performed!\e[0m";
	fi;
}
export -f gpgVerifyGitHead;

BUILD_WORKING_DIR=${PWD##*/};
export DOS_VERSION="$BUILD_WORKING_DIR";
if [ -d ".repo" ]; then
	echo "Detected $BUILD_WORKING_DIR";
else
	echo "Not a valid workspace!";
	return 1;
fi;

export DOS_BUILD_BASE="$DOS_WORKSPACE_ROOT/Build/$BUILD_WORKING_DIR/";
if [ ! -d "$DOS_BUILD_BASE" ]; then
	echo "Path mismatch! Please update init.sh!";
	return 1;
fi;

export DOS_TMP_DIR="/tmp/dos_tmp";
mkdir -p "$DOS_TMP_DIR";
export DOS_HOSTS_FILE="$DOS_TMP_DIR/hosts";
export DOS_TMP_GNUPG="$DOS_TMP_DIR/gnupg-$RANDOM";
mkdir -p "$DOS_TMP_GNUPG";
export GNUPGHOME="$DOS_TMP_GNUPG";
chmod 700 "$DOS_TMP_GNUPG";
export DOS_VERIFICATION_KEYRING="$DOS_WORKSPACE_ROOT/Misc/pubring.kbx";
cp "$DOS_VERIFICATION_KEYRING" "$DOS_TMP_GNUPG/";

export DOS_PREBUILT_APPS="$DOS_WORKSPACE_ROOT/PrebuiltApps/";
export DOS_PATCHES_COMMON="$DOS_WORKSPACE_ROOT/Patches/Common/";
export DOS_PATCHES="$DOS_WORKSPACE_ROOT/Patches/$BUILD_WORKING_DIR/";
export DOS_PATCHES_LINUX_CVES="$DOS_WORKSPACE_ROOT/Patches/Linux/";
export DOS_WALLPAPERS="$DOS_WORKSPACE_ROOT/Patches/Wallpapers/";

export DOS_SCRIPTS_COMMON="$DOS_WORKSPACE_ROOT/Scripts/Common/";
export DOS_SCRIPTS="$DOS_WORKSPACE_ROOT/Scripts/$BUILD_WORKING_DIR/";
if [ ! -d "$DOS_SCRIPTS" ]; then
	echo "$BUILD_WORKING_DIR is not supported!";
	return 1;
fi;
export DOS_SCRIPTS_CVES="$DOS_SCRIPTS/CVE_Patchers/";

export KBUILD_BUILD_USER="emy";
export KBUILD_BUILD_HOST="dosbm";
export BUILD_USERNAME="emy";
export BUILD_HOSTNAME="dosbm";

export ANDROID_JACK_VM_ARGS="-Xmx8192m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation";
export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}";
export EXPERIMENTAL_USE_JAVA8=true;
export GRADLE_OPTS="-Xmx2048m";
export TZ=:/etc/localtime;
export LC_ALL=C;
export LANG=C.UTF-8;

if [[ "$DOS_VERSION" != "LineageOS-20.0" ]] && [[ "$DOS_VERSION" != "LineageOS-21.0" ]]; then export DOS_DEBLOBBER_REMOVE_EUICC_FULL=true; fi;

#START OF VERIFICATION
gpgVerifyGitHead "$DOS_WORKSPACE_ROOT";
gpgVerifyGitHead "$DOS_PREBUILT_APPS";
gpgVerifyGitHead "$DOS_PATCHES_LINUX_CVES";
gpgVerifyGitHead "$DOS_WALLPAPERS";
#END OF VERIFICATION

source "$DOS_SCRIPTS_COMMON/Shell.sh";
source "$DOS_SCRIPTS_COMMON/Functions.sh";
source "$DOS_SCRIPTS_COMMON/Tag_Verifier.sh";
source "$DOS_SCRIPTS/Functions.sh";

[[ -f "$DOS_BUILD_BASE/.repo/local_manifests/roomservice.xml" ]] && echo "roomservice manifest found! Please fix your manifests before continuing!";
[[ -f "$DOS_BUILD_BASE/DOS_PATCHED_FLAG" ]] && echo "NOTE: THIS WORKSPACE IS ALREADY PATCHED, PLEASE RESET BEFORE PATCHING AGAIN!";

if grep -sq "orphan_file" "/etc/mke2fs.conf"; then echo "NOTE: YOU MUST REMOVE orphan_file AND metadata_csum_seed FROM /etc/mke2fs.conf"; fi;
