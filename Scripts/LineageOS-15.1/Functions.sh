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
	startPatcher "kernel_google_marlin kernel_google_msm kernel_htc_flounder kernel_htc_msm8974 kernel_huawei_angler kernel_lge_bullhead kernel_lge_g3 kernel_lge_hammerhead kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oppo_msm8974 kernel_samsung_msm8974";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf packages/apps/{FDroid,GmsCore} out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	scanQueue="$base/android $base/art $base/bionic $base/bootable $base/build $base/compatibility $base/dalvik $base/device $base/hardware $base/libcore $base/libnativehelper $base/packages $base/pdk $base/platform_testing $base/sdk $base/system";
	scanQueue=$scanQueue" $base/lineage-sdk $base/vendor/lineage";
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
	if [ "$MALWARE_SCAN_ENABLED" = true ]; then scanWorkspaceForMalware; fi;
#Select devices are userdebug due to SELinux policy issues
#TODO: hiae star2lte starlte
	brunch lineage_d852-user;
	brunch lineage_bacon-user;
	brunch lineage_mako-user;
	brunch lineage_angler-user;
	brunch lineage_bullhead-user;
	brunch lineage_d802-user; #broken upstream - error: 'vendor/lge/g2-common/proprietary/vendor/etc/acdbdata/Bluetooth_cal.acdb'
	brunch lineage_d855-user; #broken upstream - recovery updater
	brunch lineage_ether-user;
	brunch lineage_flo-user;
	brunch lineage_flounder-user;
	brunch lineage_griffin-user;
	brunch lineage_h850-userdebug;
	brunch lineage_hammerhead-user; #broken upstream - fatal error: 'linux/msm_audio_calibration.h' file not found
	brunch lineage_klte-user;
	brunch lineage_marlin-user;
	brunch lineage_m8-user;
	brunch lineage_sailfish-user;
	brunch lineage_shamu-user;
}
export -f buildAll;

patchWorkspace() {
	if [ "$MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$prebuiltApps $base/build $base/device $base/vendor/lineage"; fi;

	source build/envsetup.sh;
	repopick -f 214824 209584 209585 215010 214300; #g3-common
	repopick -f 211404 211405 211406 211407 211408 211409; #d852
	repopick -f 211396 214817; #d855

	source "$scripts/Patch.sh";
	source "$scripts/Defaults.sh";
	if [ "$OVERCLOCKS_ENABLED" = true ]; then source "$scripts/Overclock.sh"; fi;
	source "$scripts/Optimize.sh";
	source "$scripts/Rebrand.sh";
	source "$scriptsCommon/Deblob.sh";
	source "$scriptsCommon/Patch_CVE.sh";
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	cd device/lge/h850 && ./setup-makefiles.sh && cd "$base";
}
export -f patchWorkspace;

enableDexPreOpt() {
	cd "$base$1";
	if [ "$1" != "device/amazon/thor" ] && [ "$1" != "device/samsung/i9100" ] && [ "$1" != "device/lge/h850" ] && [ "$1" != "device/lge/mako" ]; then #Some devices won't compile, or have too small of a /system partition
		if [ -f BoardConfig.mk ]; then
			echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true" >> BoardConfig.mk;
			echo "Enabled dexpreopt for $1";
		fi;
	fi;
	cd "$base";
}
export -f enableDexPreOpt;

enableDexPreOptFull() {
	cd "$base$1";
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true/WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false/" BoardConfig.mk;
		echo "Enabled full dexpreopt";
	fi;
	cd "$base";
}
export -f enableDexPreOptFull;
