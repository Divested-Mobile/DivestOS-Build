#!/bin/bash
#DivestOS: A privacy oriented Android distribution
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
	startPatcher "kernel_amazon_hdx-common kernel_asus_fugu kernel_asus_grouper kernel_asus_msm8916 kernel_cyanogen_msm8916 kernel_cyanogen_msm8974 kernel_fairphone_msm8974 kernel_google_dragon kernel_google_marlin kernel_google_msm kernel_huawei_angler kernel_htc_flounder kernel_htc_msm8974 kernel_htc_msm8994 kernel_lge_bullhead kernel_lge_g3 kernel_lge_hammerhead kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8992 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8916 kernel_motorola_msm8974 kernel_motorola_msm8992 kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oneplus_msm8974 kernel_oneplus_msm8994 kernel_oneplus_msm8996 kernel_samsung_exynos5420 kernel_samsung_jf kernel_samsung_manta kernel_samsung_msm8974 kernel_samsung_smdk4412 kernel_samsung_tuna kernel_samsung_universal8890 kernel_zte_msm8996";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/abi $DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/ndk $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/vendor/cm $DOS_BUILD_BASE/vendor/cmsdk";
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
	#Select devices are userdebug due to SELinux policy issues
	buildDeviceUserDebug thor; #broken encryption
	buildDevice clark;
	buildDevice h815; #broken
	buildDevice manta;
	buildDevice n7100; #broken sepolicy
	buildDeviceUserDebug i9300;
	buildDevice i9305;
	buildDevice n5110;
	buildDevice v1awifi;
	buildDevice herolte;
	buildDevice maguro;
	buildDevice toro;
	buildDevice toroplus;
	buildDevice grouper; #needs manual patching - one-repo vendor blob patch

	#The following are all superseded, and should only be enabled if the newer version is broken (not building/booting/etc.)
	buildDevice osprey;
	buildDevice himaul;
	buildDevice Z00T;
	buildDeviceUserDebug i9100;
	if [ "$DOS_BUILDALL_SUPERSEDED" = true ]; then
		buildDevice flo;
		buildDevice mako;
		buildDevice crackling;
		buildDevice jfltexx; #broken - drivers/video/msm/mdp.c:401:1: warning: the frame size of 1032 bytes is larger than 1024 bytes [-Wframe-larger-than=]
		buildDevice d802;
		buildDevice hammerhead;
		buildDevice bacon;
		buildDevice d852;
		buildDevice d855;
		buildDevice flounder verity;
		buildDevice FP2;
		buildDevice ham;
		buildDevice klte;
		buildDevice m8;
		buildDevice victara; #needs manual patching - fwb xml: fused: dangling tag
		buildDevice shamu verity;
		buildDevice bullhead verity;
		buildDevice oneplus2;
		buildDevice ether;
		buildDevice angler verity;
		buildDevice kipper;
		buildDevice axon7;
		buildDevice oneplus3;
		buildDevice griffin;
		buildDevice h850;
		buildDevice us996;
		buildDevice marlin verity;
		buildDevice sailfish verity;
		buildDevice us997;
		buildDevice dragon verity;
		buildDevice fugu;
	fi;
}
export -f buildAll;

patchWorkspace() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/cm"; fi;
	source build/envsetup.sh;
	repopick -it n_asb_09-2018-qcom;
	repopick -it ibss-mode-nougat;
	repopick -i 285265; #update webview

	export DOS_GRAPHENE_MALLOC=false; #patches apply, compile fails

	source "$DOS_SCRIPTS/Patch.sh";
	source "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
	source "$DOS_SCRIPTS/Defaults.sh";
	source "$DOS_SCRIPTS/Rebrand.sh";
	source "$DOS_SCRIPTS/Theme.sh";
	if [ "$DOS_OVERCLOCKS_ENABLED" = true ]; then source "$DOS_SCRIPTS_COMMON/Overclock.sh"; fi;
	source "$DOS_SCRIPTS_COMMON/Optimize.sh";
	source "$DOS_SCRIPTS_COMMON/Deblob.sh";
	source "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	cd device/asus/Z00T && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
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
			echo "WITH_DEXPREOPT_BOOT_IMG_ONLY := true" >> BoardConfig.mk;
			echo "Enabled dexpreopt for $1";
		fi;
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOpt;

enableDexPreOptFull() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT_BOOT_IMG_ONLY := true/WITH_DEXPREOPT_BOOT_IMG_ONLY := false/" BoardConfig.mk;
		echo "Enabled full dexpreopt for $1";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableDexPreOptFull;

enableLowRam() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f lineage.mk ]; then echo '$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage.mk; fi;
	if [ -f BoardConfig.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfig.mk; fi;
	if [ -f BoardConfigCommon.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfigCommon.mk; fi;
	echo "Enabled lowram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableLowRam;
