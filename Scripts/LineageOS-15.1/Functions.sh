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

#Last verified: 2018-04-27

patchAllKernels() {
	startPatcher "kernel_asus_fugu kernel_essential_msm8998 kernel_fairphone_msm8974 kernel_google_dragon kernel_google_marlin kernel_google_msm kernel_htc_flounder kernel_htc_msm8974 kernel_huawei_angler kernel_lge_bullhead kernel_lge_g3 kernel_lge_hammerhead kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8974 kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oppo_msm8974 kernel_samsung_msm8974 kernel_samsung_universal9810";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	scanQueue="$DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/compatibility $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/lineage-sdk $DOS_BUILD_BASE/vendor/lineage";
	scanForMalware true $scanQueue;
}
export -f scanWorkspaceForMalware;

buildDevice() {
	brunch "lineage_$1-user";
}
export -f buildDevice;

buildDeviceDebug() {
	unset SIGNING_KEY_DIR;
	unset OTA_PACKAGE_SIGNING_KEY;
	brunch "lineage_$1-eng";
}
export -f buildDeviceDebug;

buildAll() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanWorkspaceForMalware; fi;
	brunch lineage_d852-user;
	brunch lineage_angler-user;
	brunch lineage_bullhead-user;
	brunch lineage_d802-user;
	brunch lineage_d855-user;
	brunch lineage_dragon-user;
	brunch lineage_flo-user;
	brunch lineage_flounder-user;
	brunch lineage_FP2-user;
	brunch lineage_fugu-user;
	brunch lineage_h850-user;
	brunch lineage_hammerhead-user;
	brunch lineage_m8-user;
	brunch lineage_mata-user;
	brunch lineage_starlte-user; #broken - device/samsung/universal9810-common/audio: MODULE.TARGET.SHARED_LIBRARIES.libshim_audio_32 already defined by device/samsung/star-common/audio
	brunch lineage_us996-user;
	brunch lineage_us997-user;
	brunch lineage_victara-user;

	#The following are all superseded, and should only be enabled if the newer version is broken (not building/booting/etc.)
	if [ "$DOS_BUILDALL_SUPERSEDED" = true ]; then
		brunch lineage_bacon-user;
		brunch lineage_ether-user;
		brunch lineage_griffin-user;
		brunch lineage_klte-user;
		brunch lineage_mako-user;
		brunch lineage_marlin-user;
		brunch lineage_sailfish-user;
		brunch lineage_shamu-user;
	fi;
}
export -f buildAll;

patchWorkspace() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;

	source build/envsetup.sh;
	#repopick 219020; #ab-neverallow-user
	#repopick -it bt-sbc-hd-dualchannel;
	repopick 244160; #ramdisk compression fix

	source "$DOS_SCRIPTS/Patch.sh";
	source "$DOS_SCRIPTS/Defaults.sh";
	source "$DOS_SCRIPTS/Rebrand.sh";
	if [ "$DOS_OVERCLOCKS_ENABLED" = true ]; then source "$DOS_SCRIPTS_COMMON/Overclock.sh"; fi;
	source "$DOS_SCRIPTS_COMMON/Optimize.sh";
	source "$DOS_SCRIPTS_COMMON/Deblob.sh";
	source "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	cd device/lge/h850 && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
}
export -f patchWorkspace;

enableDexPreOpt() {
	cd "$DOS_BUILD_BASE$1";
	#Some devices won't compile, or have too small of a /system partition, or Wi-Fi breaks
	if [ "$1" != "device/amazon/thor" ] && [ "$1" != "device/samsung/i9100" ] && [ "$1" != "device/samsung/maguro" ] && [ "$1" != "device/samsung/toro" ] && [ "$1" != "device/samsung/toroplus" ] && [ "$1" != "device/samsung/tuna" ] && [ "$1" != "device/lge/h850" ] && [ "$1" != "device/lge/mako" ] && [ "$1" != "device/asus/grouper" ]; then
		if [ -f BoardConfig.mk ]; then
			echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true" >> BoardConfig.mk;
			echo "Enabled dexpreopt for $1";
		fi;
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOpt;

enableDexPreOptFull() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true/WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false/" BoardConfig.mk;
		echo "Enabled full dexpreopt for $1";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOptFull;

enableLowRam() {
	cd "$DOS_BUILD_BASE$1";
	#if [ -f lineage.mk ]; then echo '$(call inherit-product, $(SRC_TARGET_DIR)/product/go_defaults.mk)' >> lineage.mk; fi;
	if [ -f lineage.mk ]; then echo '$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage.mk; fi;
	if [ -f BoardConfig.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfig.mk; fi;
	if [ -f BoardConfigCommon.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfigCommon.mk; fi;
	echo "Enabled lowram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableLowRam;
