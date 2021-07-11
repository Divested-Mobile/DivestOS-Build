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

#Last verified: 2021-03-22

patchAllKernels() {
	startPatcher "kernel_essential_msm8998 kernel_fxtec_msm8998 kernel_google_coral kernel_google_msm kernel_google_msm-4.9 kernel_google_wahoo kernel_htc_msm8974 kernel_lge_g3 kernel_lge_mako kernel_lge_msm8974 kernel_lge_msm8996 kernel_moto_shamu kernel_motorola_msm8974 kernel_nextbit_msm8992 kernel_oneplus_msm8996 kernel_oneplus_msm8998 kernel_oneplus_sdm845 kernel_oneplus_sm8150 kernel_oppo_msm8974 kernel_razer_msm8998 kernel_samsung_jf kernel_samsung_msm8930-common kernel_samsung_msm8974 kernel_xiaomi_sdm845";
}
export -f patchAllKernels;

resetWorkspace() {
	umask 0022;
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
	cd "$DOS_BUILD_BASE";
	export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
	breakfast "lineage_$1-user" && mka target-files-package otatools && processRelease $1 true $2;
}
export -f buildDevice;

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
	if [ "$DOS_OPTIMIZE_IMAGES" = true ]; then optimizeImagesRecursive "$DOS_BUILD_BASE"; fi;
	#SDS4P
	buildDevice flox;
	buildDevice mako;
	#SD400
	buildDevice serrano3gxx; #unb
	buildDevice serranoltexx; #unb
	#SD600
	buildDevice jfltexx;
	#SD800
	buildDevice d802;
	#SD801
	buildDevice bacon;
	buildDevice d852;
	buildDevice d855;
	buildDevice klte;
	buildDevice m8; #unb18
	buildDevice victara;
	#SD805
	buildDevice shamu verity;
	#SD808
	buildDevice ether;
	#SD820
	buildDevice h850;
	buildDevice rs988;
	buildDevice h990;
	buildDevice us996;
	buildDevice oneplus3 verity; #needs manual patching - broken yyloc
	#SD835
	buildDevice cheryl verity;
	buildDevice cheeseburger verity; #needs manual patching - vendor common makefile
	buildDevice dumpling verity;
	buildDevice mata verity;
	buildDevice taimen avb;
	buildDevice walleye avb;
	#SD845
	buildDevice beryllium; #needs manual patching in vendor
	buildDevice pro1 avb;
	buildDevice crosshatch avb;
	buildDevice blueline avb;
	buildDevice enchilada avb;
	buildDevice fajita avb;
	#SD855
	buildDevice guacamole avb;
	buildDevice coral avb;
	buildDevice flame avb;
	#SD670
	buildDevice bonito avb; #error: ln: cannot create symbolic link from '/data/vendor/rfs/mpss' to 'out/target/product/bonito/vendor/rfs/msm/mpss//readwrite':
	buildDevice sargo avb;
}
export -f buildAll;

patchWorkspace() {
	umask 0022;
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;

	source build/envsetup.sh;
	#repopick -i 312861; #recorder intent improvement
	repopick -it android-11.0.0_r39; #XXX: manifests change must be manually picked

	source "$DOS_SCRIPTS/Patch.sh";
	source "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
	source "$DOS_SCRIPTS/Defaults.sh";
	source "$DOS_SCRIPTS/Rebrand.sh";
	source "$DOS_SCRIPTS_COMMON/Optimize.sh";
	source "$DOS_SCRIPTS_COMMON/Deblob.sh";
	source "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	#none yet
}
export -f patchWorkspace;

enableDexPreOpt() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
		echo "WITH_DEXPREOPT_DEBUG_INFO := false" >> BoardConfig.mk;
		#m8: /system partition too small
		if [ "$1" != "device/htc/m8" ] && [ "$1" != "device/samsung/jfltexx" ]; then
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
	if [ -f lineage.mk ]; then echo -e '\n$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage.mk; fi; #TODO: handle lineage_device.mk
	if [ -f BoardConfig.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfig.mk; fi;
	if [ -f BoardConfigCommon.mk ]; then echo 'MALLOC_SVELTE := true' >> BoardConfigCommon.mk; fi;
	echo "Enabled lowram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableLowRam;
