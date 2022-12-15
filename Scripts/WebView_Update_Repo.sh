#!/bin/bash
#Copyright (c) 2021-2022 Divested Computing Group
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
umask 0022;
set -uo pipefail;

export version="108.0.5359.128-1";
export PATH=$PATH:$HOME/Android/Sdk/build-tools/33.0.0;
export webviewARM32="/mnt/dos/Repos/DivestOS_WebView/prebuilt/arm/webview.apk";
export webviewARM64="/mnt/dos/Repos/DivestOS_WebView/prebuilt/arm64/webview.apk";
export repoDir="/mnt/dos/Repos/DivestOS_WebView-FDroid/repo/";
mkdir -p $repoDir;

devicesARM32=(apollo bacon crackling d2att d2spr d2tmo d2vzw d800 d801 d802 d803 d850 d851 d852 d855 deb f400 flo flox FP2 grouper ham hammerhead harpia i9100 i9300 i9305 jflteatt jfltespr jfltevzw jfltexx kccat6 kipper klte lentislte ls990 m7 m8 m8d maguro mako manta merlin n5100 n5110 n5120 osprey serrano3gxx serranoltexx shamu surnia thor tilapia toro toroplus v1awifi victara vs985);
devicesARM64=(akari alioth Amber angler aura aurora avicii axon7 barbet beryllium bluejay blueline bonito bramble bullhead cheeseburger cheetah cheryl clark coral crosshatch davinci discovery dragon dumpling enchilada ether fajita flame flounder flounder_lte FP3 FP4 griffin guacamole guacamoleb h811 h815 h850 h870 h910 h918 h990 hero2lte herolte himaul himawl hotdog hotdogb instantnoodle instantnoodlep kebab land lavender lemonade lemonadep lmi ls997 marlin mata oneplus2 oneplus3 oriole panther pioneer pro1 raphael raven redfin rs988 sailfish santoni sargo star2lte starlte sunfish taimen us996 us997 vayu voyager vs995 walleye xz2c yellowstone Z00T z2_plus);
devicesX86=(fugu);

for device in "${devicesARM32[@]}"
do
	if [ -d "/mnt/dos/Signing_Keys/4096pro/$device/" ]; then
		cp --reflink=auto "$webviewARM32" "$repoDir/arm-$device-$version.apk";
		apksigner sign --key "/mnt/dos/Signing_Keys/4096pro/$device/releasekey.pk8" --cert "/mnt/dos/Signing_Keys/4096pro/$device/releasekey.x509.pem" "$repoDir/arm-$device-$version.apk";
	fi;
done;

for device in "${devicesARM64[@]}"
do
	if [ -d "/mnt/dos/Signing_Keys/4096pro/$device/" ]; then
		cp --reflink=auto "$webviewARM64" "$repoDir/arm64-$device-$version.apk";
		apksigner sign --key "/mnt/dos/Signing_Keys/4096pro/$device/releasekey.pk8" --cert "/mnt/dos/Signing_Keys/4096pro/$device/releasekey.x509.pem" "$repoDir/arm64-$device-$version.apk";
	fi;
done;
