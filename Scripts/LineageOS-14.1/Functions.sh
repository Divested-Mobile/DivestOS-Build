#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2022 Divested Computing Group
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

#Last verified: 2021-10-16

patchAllKernels() {
	startPatcher "kernel_amazon_hdx-common kernel_asus_grouper kernel_htc_msm8960 kernel_htc_msm8994 kernel_lge_msm8992 kernel_motorola_msm8992 kernel_samsung_d2 kernel_samsung_exynos5420 kernel_samsung_manta kernel_samsung_smdk4412 kernel_samsung_tuna kernel_samsung_universal8890";
}
export -f patchAllKernels;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/abi $DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/ndk $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/vendor/cm $DOS_BUILD_BASE/vendor/cmsdk";
	scanForMalware true "$scanQueue";
}
export -f scanWorkspaceForMalware;

buildDevice() {
	cd "$DOS_BUILD_BASE";
	export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
	pkill java && sleep 10; #XXX: ugly hack
	breakfast "lineage_$1-user" && mka -j${DOS_MAX_THREADS_BUILD} target-files-package otatools && processRelease $1 true $2;
	pkill java && sleep 10; #XXX: ugly hack
}
export -f buildDevice;

buildDeviceUserDebug() {
	cd "$DOS_BUILD_BASE";
	if [[ -d "$DOS_SIGNING_KEYS/$1" ]]; then
		export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
		breakfast "lineage_$1-userdebug" && mka -j${DOS_MAX_THREADS_BUILD} target-files-package otatools && processRelease $1 true $2;
	else
		echo -e "\e[0;31mNo signing keys available for $1\e[0m";
	fi;
}
export -f buildDeviceUserDebug;

buildDeviceDebug() {
	cd "$DOS_BUILD_BASE";
	unset OTA_KEY_OVERRIDE_DIR;
	brunch "lineage_$1-eng";
}
export -f buildDeviceDebug;

buildAll() {
	umask 0022;
	cd "$DOS_BUILD_BASE";
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanWorkspaceForMalware; fi;
	#Select devices are userdebug due to SELinux policy issues
	#SDS4P
	buildDeviceUserDebug d2att;
	buildDeviceUserDebug d2spr;
	buildDeviceUserDebug d2tmo;
	buildDeviceUserDebug d2vzw;
	#SD600
	buildDeviceUserDebug m7;
	#SD801
	buildDeviceUserDebug thor; #broken encryption
	buildDeviceUserDebug apollo;
	#SD808
	buildDevice clark; #Last version with working IMS
	buildDevice h811;
	buildDevice h815;
	#SD810
	buildDevice himaul;
	buildDevice himawl;
	#Exynos
	buildDevice manta;
	buildDeviceUserDebug i9100;
	buildDeviceUserDebug i9300;
	buildDeviceUserDebug i9305;
	buildDeviceUserDebug n5100;
	buildDeviceUserDebug n5110;
	buildDeviceUserDebug n5120;
	buildDevice v1awifi;
	buildDevice herolte;
	buildDevice hero2lte;
	#OMAP
	buildDevice maguro;
	buildDevice toro;
	buildDevice toroplus;
	#Tegra
	buildDevice grouper; #needs manual patching - one-repo vendor blob patch
}
export -f buildAll;

patchWorkspaceReal() {
	umask 0022;
	cd "$DOS_BUILD_BASE/$1";
	touch DOS_PATCHED_FLAG;
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/cm"; fi;
	verifyAllPlatformTags;
	gpgVerifyGitHead "$DOS_BUILD_BASE/external/chromium-webview";

	source build/envsetup.sh;
	repopick -fit tzdb_N;

	sh "$DOS_SCRIPTS/Patch.sh";
	sh "$DOS_SCRIPTS_COMMON/Enable_Verity.sh";
	sh "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
	sh "$DOS_SCRIPTS_COMMON/Defaults.sh";
	sh "$DOS_SCRIPTS/Rebrand.sh";
	sh "$DOS_SCRIPTS/Theme.sh";
	sh "$DOS_SCRIPTS_COMMON/Optimize.sh";
	sh "$DOS_SCRIPTS_COMMON/Deblob.sh";
	sh "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	sh "$DOS_SCRIPTS_COMMON/Post.sh";
	source build/envsetup.sh;
}
export -f patchWorkspaceReal;

enableDexPreOpt() {
	cd "$DOS_BUILD_BASE/$1";
	#Some devices won't compile, or have too small of a /system partition, or Wi-Fi breaks
	if [ "$1" != "device/amazon/thor" ] && [ "$1" != "device/amazon/apollo" ] && [ "$1" != "device/asus/grouper" ] && [ "$1" != "device/samsung/i9100" ] && [ "$1" != "device/samsung/maguro" ] && [ "$1" != "device/samsung/manta" ] && [ "$1" != "device/samsung/toro" ] && [ "$1" != "device/samsung/toroplus" ] && [ "$1" != "device/samsung/tuna" ]; then
		if [ -f BoardConfig.mk ]; then
			echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_BOOT_IMG_ONLY := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_DEBUG_INFO := false" >> BoardConfig.mk;
			echo "Enabled dexpreopt for $1";
		fi;
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOpt;

enableDexPreOptFull() {
	cd "$DOS_BUILD_BASE/$1";
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT_BOOT_IMG_ONLY := true/WITH_DEXPREOPT_BOOT_IMG_ONLY := false/" BoardConfig.mk;
		echo "Enabled full dexpreopt for $1";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOptFull;

enableLowRam() {
	if [ -d "$DOS_BUILD_BASE/$1" ]; then
		cd "$DOS_BUILD_BASE/$1";
		if [ -f lineage.mk ]; then echo -e '\n$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage.mk; fi;
		if [ -f BoardConfig.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfig.mk; fi;
		if [ -f BoardConfigCommon.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfigCommon.mk; fi;
		echo "Enabled lowram for $1";
		cd "$DOS_BUILD_BASE";
	else
		echo "Not enabling lowram for $1, not available";
	fi;
}
export -f enableLowRam;
