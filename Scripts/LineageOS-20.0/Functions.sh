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

#Last verified: 2022-10-15

patchAllKernels() {
	startPatcher "kernel_fairphone_sm7225 kernel_fxtec_msm8998 kernel_google_gs101_private_gs-google kernel_google_gs201_private_gs-google kernel_google_msm-4.9 kernel_google_msm-4.14 kernel_google_redbull kernel_google_wahoo kernel_oneplus_msm8998 kernel_oneplus_sdm845 kernel_oneplus_sm8150 kernel_oneplus_sm8250 kernel_oneplus_sm8350 kernel_razer_sdm845 kernel_xiaomi_sdm845";
}
export -f patchAllKernels;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/android $DOS_BUILD_BASE/art $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/platform_testing $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/lineage-sdk $DOS_BUILD_BASE/vendor/lineage";
	scanForMalware true "$scanQueue";
}
export -f scanWorkspaceForMalware;

buildDevice() {
	cd "$DOS_BUILD_BASE";
	#export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
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
	#SD835
	buildDevice taimen avb;
	buildDevice walleye avb;
	buildDevice cheeseburger verity;
	buildDevice dumpling verity;
	#SD845
	buildDevice fajita avb;
	buildDevice enchilada avb;
	buildDevice aura avb;
	buildDevice beryllium avb;
	buildDevice pro1 avb;
	buildDevice crosshatch avb;
	buildDevice blueline avb;
	#SD750
	buildDevice FP4 avb;
	#SD855
	buildDevice guacamole avb;
	buildDevice guacamoleb avb;
	buildDevice hotdog avb;
	buildDevice hotdogb avb;
	buildDevice coral avb;
	buildDevice flame avb;
	#SD730
	buildDevice sunfish avb;
	#SD865
	buildDevice instantnoodle avb;
	buildDevice instantnoodlep avb;
	buildDevice kebab avb;
	#SD888
	buildDevice lemonade avb;
	buildDevice lemonadep avb;
	#SD765
	buildDevice bramble avb;
	buildDevice redfin avb;
	buildDevice barbet avb;
	#SD670
	buildDevice bonito avb;
	buildDevice sargo avb;
	#Tensor
	buildDevice oriole avb;
	buildDevice raven avb;
	buildDevice bluejay avb;
	buildDevice panther avb;
	buildDevice cheetah avb;
}
export -f buildAll;

patchWorkspace() {
	umask 0022;
	cd "$DOS_BUILD_BASE$1";
	touch DOS_PATCHED_FLAG;
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;
	verifyAllPlatformTags;
	gpgVerifyGitTag "$DOS_BUILD_BASE/external/hardened_malloc";
	gpgVerifyGitTag "$DOS_BUILD_BASE/external/SecureCamera";
	gpgVerifyGitHead "$DOS_BUILD_BASE/external/chromium-webview";

	source build/envsetup.sh;
	repopick -it T_tzdb2022f;

	sh "$DOS_SCRIPTS/Patch.sh";
	sh "$DOS_SCRIPTS_COMMON/Enable_Verity.sh";
	sh "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
	sh "$DOS_SCRIPTS/Defaults.sh";
	sh "$DOS_SCRIPTS/Rebrand.sh";
	sh "$DOS_SCRIPTS_COMMON/Optimize.sh";
	sh "$DOS_SCRIPTS_COMMON/Deblob.sh";
	sh "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	sh "$DOS_SCRIPTS_COMMON/Post.sh";
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
		if true; then
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
	if [ -f lineage_$2.mk ]; then echo -e '\n$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage_$2.mk; fi;
	echo "Enabled lowram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableLowRam;
