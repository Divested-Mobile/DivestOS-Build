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

#Last verified: 2020-04-14

patchAllKernels() {
	startPatcher "kernel_cyanogen_msm8916 kernel_essential_msm8998 kernel_fairphone_msm8974 kernel_fxtec_msm8998 kernel_google_coral kernel_google_marlin kernel_google_msm kernel_google_msm-4.9 kernel_google_wahoo kernel_google_yellowstone kernel_htc_msm8974 kernel_lge_g3 kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8916 kernel_motorola_msm8974 kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oneplus_msm8994 kernel_oneplus_msm8996 kernel_oneplus_msm8998 kernel_oneplus_sdm845 kernel_oneplus_sm8150 kernel_oppo_msm8974 kernel_razer_msm8998 kernel_samsung_jf kernel_samsung_msm8974 kernel_samsung_universal9810 kernel_xiaomi_sdm845 kernel_yandex_sdm660 kernel_zuk_msm8996";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
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
	#SDS4P
	buildDevice flox;
	buildDevice mako;
	#SD410
	buildDevice crackling;
	#buildDevice osprey; #needs manual patching + more - mkdir proprietary/priv-app && cp -r proprietary/system/priv-app/qcrilmsgtunnel proprietary/priv-app/
	#SD600
	buildDevice jfltexx;
	#SD800
	buildDevice d802;
	#SD801
	buildDevice bacon;
	buildDevice d852;
	buildDevice d855;
	buildDevice FP2;
	buildDevice klte;
	buildDevice m8;
	buildDevice victara; #error: +out/target/product/victara/recovery.img too large (10522624 >= 10485760)
	#SD805
	buildDevice shamu verity;
	#SD808
	buildDevice ether;
	#SD810
	buildDevice oneplus2;
	#SD820
	buildDevice h850;
	buildDevice us996;
	buildDevice griffin;
	buildDevice oneplus3 verity;
	buildDevice z2_plus verity;
	#SD821
	buildDevice marlin verity;
	buildDevice sailfish verity;
	#SD835
	buildDevice cheryl;
	buildDevice cheeseburger verity; #needs manual patching - vendor common makefile + not booting
	buildDevice dumpling verity;
	buildDevice mata verity;
	buildDevice taimen avb;
	buildDevice walleye avb;
	#SD845
	buildDevice beryllium; #needs manual patching in vendor
	buildDevice crosshatch avb;
	buildDevice blueline avb;
	buildDevice enchilada avb;
	buildDevice fajita avb;
	buildDevice pro1 avb;
	#SD855
	buildDevice guacamole avb;
	buildDevice guacamoleb avb;
	buildDevice coral avb;
	buildDevice flame avb;
	#SD660
	buildDevice Amber verity;
	#SD670
	buildDevice bonito avb;
	buildDevice sargo avb;
	#Exynos
	buildDevice starlte;
	#Tegra
	buildDevice yellowstone; #broken
}
export -f buildAll;

patchWorkspace() {
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;

	source build/envsetup.sh;
	repopick -i 287339; #releasetools: python3 fix
	#repopick -it CVE-2019-2306;
	#repopick -i 289186;

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
	cd device/google/marlin/marlin && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
	cd device/google/marlin/sailfish && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
}
export -f patchWorkspace;

enableDexPreOpt() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
		echo "WITH_DEXPREOPT_DEBUG_INFO := false" >> BoardConfig.mk;
		#m8: /system partition too small
		if [ "$1" != "device/htc/m8" ]; then
			echo "WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := false" >> BoardConfig.mk;
			echo "Enabled full dexpreopt for $1";
		else
			echo "WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true" >> BoardConfig.mk;
			echo "Enabled core dexpreopt for $1";
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
