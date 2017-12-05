#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2015-2017 Spot Communications, Inc.
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

#Delete Everything and Sync
#repo forall -c 'git add -A && git reset --hard' && rm -rf packages/apps/{FDroid,GmsCore,Silence} out && repo sync -j20 --force-sync

#Apply all of our changes
#source ../../Scripts/LineageOS-14.1/00init.sh && source $scripts/Patch.sh && source $scripts/Defaults.sh && source $scripts/Optimize.sh && source $scripts/Rebrand.sh && source $scripts/Theme.sh && source $scripts/Deblob.sh && source $scripts/Patch_CVE.sh && source build/envsetup.sh

#Build!
#brunch lineage_mako-user && export OTA_PACKAGE_SIGNING_KEY=../../Signing_Keys/releasekey && export SIGNING_KEY_DIR=../../Signing_Keys && brunch lineage_clark-user && brunch lineage_bacon-user && brunch lineage_thor-userdebug && brunch lineage_angler-user && brunch lineage_bullhead-user && brunch lineage_ether-user && brunch lineage_flounder-user && brunch lineage_flo-user && brunch lineage_FP2-user && brunch lineage_hammerhead-user && brunch lineage_himaul-user && brunch lineage_i9100-userdebug && brunch lineage_i9305-user && brunch lineage_jfltexx-user && brunch lineage_klte-user && brunch lineage_m8-user && brunch lineage_marlin-user && brunch lineage_n5110-user && brunch lineage_osprey-user && brunch lineage_sailfish-user && brunch lineage_shamu-user && brunch lineage_Z00T-user
#XXX: Currently broken
#	lineage_herolte-user - missing libprotobuf-cpp-full.so
#TODO: Add victara, griffin, athene

#Generate an incremental
#./build/tools/releasetools/ota_from_target_files --block -t 8 -i old.zip new.zip update.zip

#Generate firmware deblobber
#mka firmware_deblobber

#
#START OF PREPRATION
#
#Download some (non-executable) out-of-tree files for use later on
mkdir /tmp/ar
cd /tmp/ar
wget https://spotco.us/hosts -N #XXX: /hosts is built from non-commercial use files, switch to /hsc for release

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses"
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

enter() {
	echo "================================================================================================"
	dir=$1;
	cd $base$dir;
	echo "[ENTERING] "$dir;
	git add -A && git reset --hard;
}

enableDexPreOpt() {
	echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
	echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
	echo "Enabled dexpreopt";
}

disableDexPreOpt() {
	sed -i 's/WITH_DEXPREOPT := true/WITH_DEXPREOPT := false/' BoardConfig.mk;
	sed -i 's/WITH_DEXPREOPT_PIC := true/WITH_DEXPREOPT_PIC := false/' BoardConfig.mk;
	echo "Disabled dexpreopt";
}

enhanceLocation() {
	cd $base$1;
	#Enable GLONASS
	sed -i 's/#A_GLONASS_POS_PROTOCOL_SELECT/A_GLONASS_POS_PROTOCOL_SELECT/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's/A_GLONASS_POS_PROTOCOL_SELECT = 0.*/A_GLONASS_POS_PROTOCOL_SELECT = 15/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's|A_GLONASS_POS_PROTOCOL_SELECT=0.*</item>|A_GLONASS_POS_PROTOCOL_SELECT=15</item>|' overlay/frameworks/base/core/res/res/values-*/*.xml &>/dev/null || true;
	#Recommended reading: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#XTRA: Only use specified URLs
	sed -i 's|XTRA_SERVER_QUERY=1|XTRA_SERVER_QUERY=0|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's|#XTRA_SERVER|XTRA_SERVER|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Enable HTTPS
	sed -i 's|http://xtra|https://xtra|' overlay/frameworks/base/core/res/res/values-*/*.xml gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Use format version 3 if possible
	if grep -sq "XTRA_VERSION_CHECK" gps.conf gps/gps.conf configs/gps.conf; then #Using hardware/qcom/gps OR precompiled blob OR device specific implementation
		sed -i 's|XTRA_VERSION_CHECK=0|XTRA_VERSION_CHECK=1|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
		sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	elif grep -sq "BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true" BoardConfig.mk boards/*gps.mk; then
		if ! grep -sq "USE_DEVICE_SPECIFIC_LOC_API := true" BoardConfig.mk boards/*gps.mk; then
			if ! grep -sq "libloc" *proprietary*.txt; then #Using hardware/qcom/gps
				sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
			fi;
		fi;
	fi;
	echo "Enhanced location services for $1";
	cd $base;
}
export -f enhanceLocation;

enableZram() {
	cd $base$1;
	sed -i 's|#/dev/block/zram0|/dev/block/zram0|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
	echo "Enabled zram for $1";
	cd $base;
}

enabledForcedEncryption() {
	cd $base$1;
	if [[ $1 != *"mako"* ]]; then
		sed -i 's|encryptable=/|forceencrypt=/|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
		echo "Enabled forceencrypt for $1";
	fi;
	cd $base;
}
export -f enabledForcedEncryption;
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#
enter "build"
patch -p1 < $patches"android_build/0001-Automated_Build_Signing.patch" #Automated build signing. Disclaimer: From CopperheadOS 13.0
sed -i 's/messaging/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence

enter "device/qcom/sepolicy"
patch -p1 < $patches"android_device_qcom_sepolicy/0001-Camera_Fix.patch" #Fix camera on user builds

enter "external/sqlite"
patch -p1 < $patches"android_external_sqlite/0001-Secure_Delete.patch" #Enable secure_delete by default. Disclaimer: From CopperheadOS 13.0

enter "frameworks/base"
git revert 0326bb5e41219cf502727c3aa44ebf2daa19a5b3 #re-enable doze on devices without gms
git fetch https://review.lineageos.org/LineageOS/android_frameworks_base refs/changes/75/151975/38 && git cherry-pick FETCH_HEAD #network traffic
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox
sed -i 's/com.android.messaging/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|config_permissionReviewRequired">false|config_permissionReviewRequired">true|' core/res/res/values/config.xml; #XXX: Super awesome, but breaks quick tiles
#See https://github.com/CopperheadOS/platform_frameworks_opt_net_wifi/commit/c2a2f077a902226093b25c563e0117e923c7495b
patch -p1 < $patches"android_frameworks_base/0001-Reduced_Resolution.patch" #Allow reducing resolution to save power TODO: Add 800x480
#patch -p1 < $patches"android_frameworks_base/0002-Radio.patch" #Add a QS tile to control radio power #TODO: Breaks cell and SystemUI
patch -p1 < $patches"android_frameworks_base/0003-Signature_Spoofing.patch" #Allow packages to spoof their signature (MicroG)
patch -p1 < $patches"android_frameworks_base/0005-Harden_Sig_Spoofing.patch" #Restrict signature spoofing to system apps signed with the platform key
rm -rf packages/PrintRecommendationService; #App that just creates popups to install proprietary print apps
rm core/res/res/values/config.xml.orig core/res/res/values/strings.xml.orig

#enter "frameworks/opt/net/ims"
#patch -p1 < $patches"android_frameworks_opt_net_ims/0001-Fix_Calling.patch" #Fix calling after we remove IMS

enter "packages/apps/CMParts"
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml #Nuke part of CMStats
git fetch https://review.lineageos.org/LineageOS/android_packages_apps_CMParts refs/changes/15/113415/26 && git cherry-pick FETCH_HEAD #network traffic
sed -i 's|config_showWeatherMenu">true|config_showWeatherMenu">false|' res/values/config.xml; #Disable Weather
patch -p1 < $patches"android_packages_apps_CMParts/0001-Remove_Analytics.patch" #Remove the rest of CMStats
patch -p1 < $patches"android_packages_apps_CMParts/0002-Reduced_Resolution.patch" #Allow reducing resolution to save power

enter "packages/apps/FakeStore"
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/ln -s /ln -sf /' Android.mk;
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;

enter "packages/apps/FDroid"
patch -p1 < $patches"android_packages_apps_FDroid/0001.patch" #Mark as privileged
cp $patches"android_packages_apps_FDroid/default_repos.xml" app/src/main/res/values/default_repos.xml; #Add extra repos
sed -i 's|gradle|./gradlew|' Android.mk; #Gradle 4.0 fix
sed -i 's|/$(fdroid_dir) \&\&| \&\&|' Android.mk; #One line wouldn't work... no matter what I tried.

enter "packages/apps/FDroidPrivilegedExtension"
patch -p1 < $patches"android_packages_apps_FDroidPrivilegedExtension/0002-Release_Key.patch" #Change to release key
#release-keys: CB:1E:E2:EC:40:D0:5E:D6:78:F4:2A:E7:01:CD:FA:29:EE:A7:9D:0E:6D:63:32:76:DE:23:0B:F3:49:40:67:C3
#test-keys: C8:A2:E9:BC:CF:59:7C:2F:B6:DC:66:BE:E2:93:FC:13:F2:FC:47:EC:77:BC:6B:2B:0D:52:C1:1F:51:19:2A:B8

enter "packages/apps/GmsCore"
git submodule update --init --recursive

enter "packages/apps/GsfProxy"
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;

enter "packages/apps/IchnaeaNlpBackend"
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/compileSdkVersion 23/compileSdkVersion 25/' build.gradle;
sed -i 's/buildToolsVersion "23.0.2"/buildToolsVersion "25.0.3"/' build.gradle;

enter "packages/apps/Jelly"
git apply --3way $patches"android_packages_apps_Jelly/182322-3.patch" #Add option to remove identifying headers

enter "packages/apps/PackageInstaller"
patch -p1 < $patches"android_packages_apps_PackageInstaller/64d8b44.diff" #Fix an issue with Permission Review

enter "packages/apps/Settings"
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 32;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; #MicroG doesn't support Backup, hide the options

enter "packages/apps/SetupWizard"
patch -p1 < $patches"android_packages_apps_SetupWizard/0001-Remove_Analytics.patch" #Remove the rest of CMStats

enter "packages/apps/Silence"
cp $patches"android_packages_apps_Silence/Android.mk" Android.mk #Add a build file

enter "packages/apps/Updater"
patch -p1 < $patches"android_packages_apps_Updater/0001-Server.patch" #Switch to our server

enter "packages/apps/WallpaperPicker"
rm res/drawable-nodpi/{*.png,*.jpg} res/values-nodpi/wallpapers.xml; #Remove old ones
cp -r $dosWallpapers'Compressed/.' res/drawable-nodpi/; #Add ours
cp -r $dosWallpapers"Thumbs/." res/drawable-nodpi/;
cp $dosWallpapers"wallpapers.xml" res/values-nodpi/wallpapers.xml;
sed -i 's/req.touchEnabled = touchEnabled;/req.touchEnabled = true;/' src/com/android/wallpaperpicker/WallpaperCropActivity.java; #Allow scrolling
sed -i 's/mCropView.setTouchEnabled(req.touchEnabled);/mCropView.setTouchEnabled(true);/' src/com/android/wallpaperpicker/WallpaperCropActivity.java;
sed -i 's/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0);/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0.5f);/' src/com/android/wallpaperpicker/WallpaperPickerActivity.java; #Center aligned by default

enter "packages/inputmethods/LatinIME"
patch -p1 < $patches"android_packages_inputmethods_LatinIME/0001-Voice.patch" #Remove voice input key

enter "packages/services/Telephony"
patch -p1 < $patches"android_packages_services_Telephony/0001-LTE_Only.patch" #LTE only preferred network mode choice. Disclaimer: From CopperheadOS before their LICENSE was added

enter "system/core"
cat /tmp/ar/hosts >> rootdir/etc/hosts #Merge in our HOSTS file
patch -p1 < $patches"android_system_core/0001-Harden_Mounts.patch" #Harden mounts with nodev/noexec/nosuid. Disclaimer: From CopperheadOS 13.0

enter "system/vold"
#XXX: THESE VALUES MUST *NOT* EVER BE CHANGED AFTER RELEASE!
#sed -i 's|define HASH_COUNT 2000|define HASH_COUNT 6000|' cryptfs.c; #Increase pbkdf iterations
#sed -i 's|define KEY_LEN_BYTES 16|define KEY_LEN_BYTES 32|' cryptfs.c; #128-bit -> 256-bit
#sed -i 's|define IV_LEN_BYTES 16|define IV_LEN_BYTES 32|' cryptfs.c;
#sed -i 's|define RSA_KEY_SIZE 2048|define RSA_KEY_SIZE 4096|' cryptfs.c; #Increase signning key size to 4096
sed -i 's|define RETRY_MOUNT_DELAY_SECONDS 1|define RETRY_MOUNT_DELAY_SECONDS 3|' cryptfs.c;

enter "vendor/cm"
rm -rf overlay/common/vendor/cmsdk/packages #Remove analytics
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
patch -p1 < $patches"android_vendor_cm/0001-SCE.patch" #Include our extras such as MicroG and F-Droid
cp $patches"android_vendor_cm/sce.mk" config/sce.mk
cp $patches"android_vendor_cm/config.xml" overlay/common/vendor/cmsdk/cm/res/res/values/config.xml; #Per app performance profiles
cp -r $patches"android_vendor_cm/firmware_deblobber" .;
cp $patches"android_vendor_cm/firmware_deblobber.mk" build/tasks/firmware_deblobber.mk;
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
sed -i 's/messaging/Silence/' config/telephony.mk; #Replace AOSP Messaging app with Silence
#sed -i 's/mka bacon/mka bacon target-files-package dist/' build/envsetup.sh; #Create target-files for incrementals

enter "vendor/cmsdk"
git fetch https://review.lineageos.org/LineageOS/cm_platform_sdk refs/changes/21/148321/14 && git cherry-pick FETCH_HEAD #network traffic
awk -i inplace '!/WeatherManagerServiceBroker/' cm/res/res/values/config.xml; #Disable Weather
cp $patches"cm_platform_sdk/profile_default.xml" cm/res/res/xml/profile_default.xml; #Replace default profiles with *way* better ones
#patch -p1 < $patches"cm_platform_sdk/0001-Radio.patch" #Add a QS tile to control radio power
sed -i 's/shouldUseOptimizations(weight)/true/' cm/lib/main/java/org/cyanogenmod/platform/internal/PerformanceManagerService.java; #Per app performance profiles fix
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enter "device/motorola/clark"
#enableDexPreOpt
patch -p1 < $patches"android_device_motorola_clark/0001-Tri_State_Torch.patch" #Tri-state torch
#TODO: Remove releasetools firmware script, as it soft bricks the radio when flashing via AOSP recovery

enter "device/oneplus/bacon"
enableDexPreOpt
sed -i "s/TZ.BF.2.0-2.0.0134/TZ.BF.2.0-2.0.0134|TZ.BF.2.0-2.0.0137/" board-info.txt; #Suport new TZ firmware https://review.lineageos.org/#/c/178999/

enter "kernel/oneplus/msm8974"
patch -p1 < $patches"android_kernel_oneplus_msm8974/0001-OverUnderClock-EXTREME.patch" #300Mhz -> 268Mhz, 2.45Ghz -> 2.95Ghz	=+2.02Ghz XXX: Not 100% stable under intense workloads

enter "device/lge/mako"
disableDexPreOpt #bootloops
#patch -p1 < $patches"android_device_lge_mako/0001-Enable_LTE.patch" #Enable LTE support (Requires LTE hybrid modem to be flashed) XXX: Doesn't seem to work under 7.x

enter "kernel/lge/hammerhead"
patch -p1 < $patches"android_kernel_lge_hammerhead/0001-OverUnderClock.patch" #2.26Ghz -> 2.95Ghz	=+2.76Ghz XXX: Untested!

enter "kernel/motorola/msm8916"
patch -p1 < $patches"android_kernel_motorola_msm8916/0001-Overclock.patch" #1.36Ghz -> 1.88Ghz	=+ 2.07Ghz XXX: Untested!

#Make changes to all devices
cd $base
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enhanceLocation "$0"' {} \;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enabledForcedEncryption "$0"' {} \;
cd $base
#
#END OF DEVICE CHANGES
#
