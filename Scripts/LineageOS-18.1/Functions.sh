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
umask 0022;

#Last verified: 2021-10-16

patchAllKernels() {
	startPatcher "kernel_fairphone_msm8974 kernel_google_marlin kernel_google_msm kernel_htc_msm8974 kernel_lge_g3 kernel_lge_mako kernel_lge_msm8974 kernel_moto_shamu kernel_motorola_msm8974 kernel_motorola_msm8996 kernel_nextbit_msm8992 kernel_oneplus_msm8996 kernel_oppo_msm8974 kernel_samsung_jf kernel_samsung_msm8930-common kernel_samsung_msm8974 kernel_xiaomi_sdm660 kernel_xiaomi_sdm845 kernel_zuk_msm8996";
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
	if [[ -d "$DOS_SIGNING_KEYS/$1" ]]; then
		export OTA_KEY_OVERRIDE_DIR="$DOS_SIGNING_KEYS/$1";
		breakfast "lineage_$1-user" && mka -j${DOS_MAX_THREADS_BUILD} target-files-package otatools && processRelease $1 true $2;
	else
		echo -e "\e[0;31mNo signing keys available for $1\e[0m";
	fi;
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
	#SDS4P
	buildDevice flox && rm device/asus/flox/sensors/Android.bp;
	buildDevice mako;
	#SD400
	buildDevice serrano3gxx; #unb
	buildDevice serranoltexx; #unb
	buildDevice serranodsdd; #unb
	#SD600
	buildDevice jactivelte;
	buildDevice jfltexx;
	buildDevice jflteatt;
	buildDevice jfltespr;
	buildDevice jfltevzw;
	buildDevice jfvelte;
	#SD800
	buildDevice d800;
	buildDevice d801;
	buildDevice d802;
	buildDevice d803;
	#SD801
	buildDevice bacon;
	buildDevice d850;
	buildDevice d851;
	buildDevice d852;
	buildDevice d855;
	buildDevice f400;
	buildDevice ls990;
	buildDevice vs985;
	buildDevice FP2;
	buildDevice klte;
	buildDevice hlte;
	buildDevice m8; #unb
	buildDevice m8d; #unb
	buildDevice victara;
	#SD805
	buildDevice shamu verity;
	#SD808
	buildDevice ether;
	#SD820
	buildDevice griffin;
	buildDevice oneplus3 verity; #needs manual patching - broken yyloc
	buildDevice z2_plus verity; #broken
	#SD821
	buildDevice marlin verity;
	buildDevice sailfish verity;
	buildDevice lavender avb;
	buildDevice jasmine_sprout avb;
	buildDevice platina avb;
	buildDevice twolip avb;
	buildDevice wayne avb;
	buildDevice whyred avb;
}
export -f buildAll;

patchWorkspaceReal() {
	umask 0022;
	cd "$DOS_BUILD_BASE/$1";
	touch DOS_PATCHED_FLAG;
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/lineage"; fi;
	verifyAllPlatformTags;
	gpgVerifyGitHead "$DOS_BUILD_BASE/external/chromium-webview";

	#source build/envsetup.sh;
	#repopick -it eleven-firewall;
	#repopick -i 314453; #TaskViewTouchController: Null check current animation on drag
	#repopick -i 325011; #lineage: Opt-in to shipping full recovery image by default

	sh "$DOS_SCRIPTS/Patch.sh";
	sh "$DOS_SCRIPTS_COMMON/Enable_Verity.sh";
	sh "$DOS_SCRIPTS_COMMON/Copy_Keys.sh";
	sh "$DOS_SCRIPTS_COMMON/Defaults.sh";
	sh "$DOS_SCRIPTS/Rebrand.sh";
	sh "$DOS_SCRIPTS_COMMON/Optimize.sh";
	sh "$DOS_SCRIPTS_COMMON/Deblob.sh";
	sh "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	sh "$DOS_SCRIPTS_COMMON/Post.sh";
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	cd device/google/marlin/marlin && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
	cd device/google/marlin/sailfish && ./setup-makefiles.sh && cd "$DOS_BUILD_BASE";
}
export -f patchWorkspaceReal;

enableDexPreOpt() {
	cd "$DOS_BUILD_BASE/$1";
	if [ -f BoardConfig.mk ]; then
		echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
		echo "WITH_DEXPREOPT_DEBUG_INFO := false" >> BoardConfig.mk;
		#m8*, jflte*: /system partition too small
		if [ "$1" != "device/htc/m8" ] && [ "$1" != "device/htc/m8d" ] && [ "$1" != "device/samsung/jactivelte" ] &&  [ "$1" != "device/samsung/jfltexx" ] && [ "$1" != "device/samsung/jflteatt" ] && [ "$1" != "device/samsung/jfltespr" ] && [ "$1" != "device/samsung/jfltevzw" ] && [ "$1" != "device/samsung/jfvelte" ]; then
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
	if [ -d "$DOS_BUILD_BASE/$1" ]; then
		cd "$DOS_BUILD_BASE/$1";
		if [ -f lineage_$2.mk ]; then echo -e '\n$(call inherit-product, vendor/divested/build/target/product/lowram.mk)' >> lineage_$2.mk; fi;
		echo "Enabled lowram for $1";
		cd "$DOS_BUILD_BASE";
	else
		echo "Not enabling lowram for $1, not available";
	fi;
}
export -f enableLowRam;
