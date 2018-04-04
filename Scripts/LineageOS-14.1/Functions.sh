#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Spot Communications, Inc.
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

patchAllKernels() {
	startPatcher "kernel_amazon_hdx-common kernel_asus_msm8916 kernel_fairphone_msm8974 kernel_google_marlin kernel_htc_msm8974 kernel_htc_msm8994 kernel_lge_g3 kernel_lge_hammerhead kernel_lge_mako kernel_lge_msm8992 kernel_lge_msm8996 kernel_motorola_msm8916 kernel_motorola_msm8992 kernel_nextbit_msm8992 kernel_oneplus_msm8974 kernel_samsung_jf kernel_samsung_msm8974 kernel_samsung_smdk4412 kernel_samsung_universal8890";
}
export -f patchAllKernels;

resetWorkspace() {
	repo forall -c 'git add -A && git reset --hard' && rm -rf packages/apps/{FDroid,GmsCore} out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

buildDevice() {
	brunch lineage_$1-user;
}
export -f buildDevice;

buildAll() {
#Select devices are userdebug due to SELinux policy issues
#TODO: Add victara, griffin, athene, us997, us996, pme, t0lte, hlte
	brunch lineage_d852-userdebug;
	brunch lineage_bacon-user;
	brunch lineage_thor-userdebug;
	brunch lineage_mako-user;
	brunch lineage_clark-user;
	brunch lineage_d855-userdebug;
	brunch lineage_ether-user;
	brunch lineage_FP2-user;
#	brunch lineage_h815-user; - (UPSTREAM) drivers/input/touchscreen/DS5/RefCode_CustomerImplementation.c:147:1: warning: the frame size of 2064 bytes is larger than 2048 bytes
	brunch lineage_h850-userdebug;
	brunch lineage_hammerhead-user;
#	brunch lineage_herolte-user; - net/netfilter/nfnetlink.c:328:14: error: 'NFNL_BATCH_FAILURE' undeclared (first use in this function)
	brunch lineage_himaul-user;
	brunch lineage_i9100-userdebug;
	brunch lineage_i9305-user;
	brunch lineage_jfltexx-user;
	brunch lineage_klte-user;
	brunch lineage_m8-user;
	brunch lineage_marlin-user;
	brunch lineage_n5110-user;
	brunch lineage_osprey-user;
	brunch lineage_sailfish-user;
	brunch lineage_Z00T-user;
}
export -f buildAll;

patchWorkspace() {
	source build/envsetup.sh;
	repopick 201223; #Cherry picks

	source $scripts/Patch.sh;
	source $scripts/Defaults.sh;
	source $scripts/Overclock.sh;
	source $scripts/Optimize.sh;
	source $scripts/Rebrand.sh;
	source $scripts/Theme.sh;
	source $scriptsCommon/Deblob.sh;
	source $scriptsCommon/Patch_CVE.sh;
	source build/envsetup.sh;

	#Deblobbing fixes
	##setup-makefiles doesn't execute properly for some devices, running it twice seems to fix whatever is wrong
	cd device/asus/Z00T && ./setup-makefiles.sh && cd $base
	cd device/lge/h850 && ./setup-makefiles.sh && cd $base

	##Fixes marlin building, really janky (recursive symlinks) and probably not the best place for it [LAOS SPECIFIC]
	cd vendor/google/marlin/proprietary;
	ln -s . vendor;
	ln -s . lib/lib;
	ln -s . lib64/lib64;
	ln -s . app/app;
	ln -s . bin/bin;
	ln -s . etc/etc;
	ln -s . framework/framework;
	ln -s . priv-app/priv-app;
	cd $base;
}
export -f patchWorkspace;

enableDexPreOpt() {
	cd $base$1;
	if [ $1 != "device/amazon/thor" ] && [ $1 != "device/samsung/i9100" ] && [ $1 != "device/lge/h850" ] && [ $1 != "device/lge/mako" ]; then #Some devices won't compile, or have too small of a /system partition
		if [ -f BoardConfig.mk ]; then
			echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
			echo "WITH_DEXPREOPT_BOOT_IMG_ONLY := true" >> BoardConfig.mk;
			echo "Enabled dexpreopt for $1";
		fi;
	fi;
	cd $base;
}
export -f enableDexPreOpt;

enableDexPreOptFull() {
	cd $base$1;
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT_BOOT_IMG_ONLY := true/WITH_DEXPREOPT_BOOT_IMG_ONLY := false/" BoardConfig.mk;
		echo "Enabled full dexpreopt";
	fi;
	cd $base;
}
export -f enableDexPreOptFull;
