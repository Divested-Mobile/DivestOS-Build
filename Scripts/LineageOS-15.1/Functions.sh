#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2020 Divested Computing Group
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
	startPatcher "kernel_asus_fugu kernel_asus_msm8916 kernel_cyanogen_msm8916 kernel_cyanogen_msm8974 kernel_essential_msm8998 kernel_fairphone_msm8974 kernel_google_dragon kernel_google_marlin kernel_google_msm kernel_google_wahoo kernel_google_yellowstone kernel_htc_flounder kernel_htc_msm8974 kernel_htc_msm8994 kernel_huawei_angler kernel_lge_bullhead kernel_lge_g3 kernel_lge_hammerhead kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8974 kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oneplus_msm8994 kernel_oneplus_msm8996 kernel_oneplus_msm8998 kernel_oneplus_sdm845 kernel_oppo_msm8974 kernel_samsung_msm8974 kernel_samsung_smdk4412 kernel_samsung_universal9810 kernel_xiaomi_sdm845 kernel_zte_msm8996";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/compatibility $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/lineage-sdk $DOS_BUILD_BASE/vendor/lineage";
	scanForMalware true "$scanQueue";
}
export -f scanWorkspaceForMalware;

buildDevice() {
	export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
	brunch "lineage_$1-user" && processRelease $1 true $2;
}
export -f buildDevice;

buildDeviceUserDebug() {
	export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
	brunch "lineage_$1-userdebug" && processRelease $1 true $2;
}
export -f buildDeviceUserDebug;

buildDeviceDebug() {
	unset OTA_KEY_OVERRIDE_DIR;
	brunch "lineage_$1-eng";
}
export -f buildDeviceDebug;

buildAll() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanWorkspaceForMalware; fi;
	if [ "$DOS_OPTIMIZE_IMAGES" = true ]; then optimizeImagesRecursive "$DOS_BUILD_BASE"; fi;
	buildDevice bullhead verity;
	#buildDevice himaul; #broken - needs vendor bits
	buildDevice angler verity;
	buildDevice Z00T; #broken - needs vendor patching
	buildDevice axon7; #broken - needs vendor patching
	buildDevice us997;
	buildDevice flounder verity;
	buildDevice dragon verity;

	#The following are all superseded, and should only be enabled if the newer version is broken (not building/booting/etc.)
	buildDevice flo;
	buildDevice fugu;
	if [ "$DOS_BUILDALL_SUPERSEDED" = true ]; then
		buildDevice mako;
		buildDevice crackling;
		buildDevice d802;
		buildDevice bacon;
		buildDevice d852;
		buildDevice d855;
		buildDevice FP2;
		buildDevice ham;
		buildDevice hammerhead;
		buildDevice klte;
		buildDevice m8;
		buildDevice victara;
		buildDevice shamu verity;
		buildDevice oneplus2;
		buildDevice ether;
		buildDevice kipper;
		buildDevice oneplus3;
		buildDevice us996;
		buildDevice h850; #broken
		buildDevice griffin;
		buildDevice marlin verity;
		buildDevice sailfish verity;
		buildDevice cheeseburger;
		buildDevice dumpling;
		buildDevice mata verity;
		buildDevice taimen avb;
		buildDevice walleye avb;
		buildDevice beryllium;
		buildDevice enchilada avb;
		buildDeviceUserDebug i9100;
		buildDevice starlte; #broken - device/samsung/universal9810-common/audio: MODULE.TARGET.SHARED_LIBRARIES.libshim_audio_32 already defined by device/samsung/star-common/audio
		buildDevice yellowstone;
	fi;
}
export -f buildAll;

patchWorkspace() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;

	source build/envsetup.sh;
	repopick -i 293123; #update webview

	export DOS_GRAPHENE_MALLOC=false; #patches apply, compile fails

	source "$DOS_SCRIPTS/Patch.sh";
	source "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
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
	if [ "$1" != "device/lge/h850" ] && [ "$1" != "device/lge/mako" ]; then
		if [ -f BoardConfig.mk ]; then
			echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_DEBUG_INFO := false" >> BoardConfig.mk;
			echo "Enabled full dexpreopt for $1";
		fi;
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOpt;

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
