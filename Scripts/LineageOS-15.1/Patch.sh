#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2015-2018 Divested Computing, Inc.
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

#Initialize aliases
#source ../../Scripts/LineageOS-15.1/00init.sh

#Delete Everything and Sync
#resetWorkspace

#Apply all of our changes
#patchWorkspace

#Build!
#buildDevice [device]
#buildAll

#Generate an incremental
#./build/tools/releasetools/ota_from_target_files --block -t 8 -i old.zip new.zip update.zip

#Generate firmware deblobber
#mka firmware_deblobber

#
#START OF PREPRATION
#
#Download some (non-executable) out-of-tree files for use later on
mkdir /tmp/ar;
cd /tmp/ar;
if [ "$HOSTS_BLOCKING" = true ]; then wget https://spotco.us/hosts -N; fi; #XXX: /hosts is built from non-commercial use files, switch to /hsc for release

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses";
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$ANDROID_HOME/licenses/android-sdk-license";
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license";
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#

#top dir
cp -r $prebuiltApps"Fennec_DOS-Shim" $base"packages/apps/"; #Add a shim to install Fennec DOS without actually including the large APK
cp -r $prebuiltApps"android_vendor_FDroid_PrebuiltApps/." $base"vendor/fdroid_prebuilt/"; #Add the prebuilt apps

enterAndClear "build/make";
patch -p1 < $patches"android_build/0001-Automated_Build_Signing.patch"; #Automated build signing (CopperheadOS-13.0)
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_build/Copperhead/0002-Deny_USB.patch"; fi; #Deny USB support (Copperhead CC BY-NC-SA)
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' core/product.mk;
sed -i 's/messaging/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence
sed -i 's/ro.secure=0/ro.secure=1/' core/main.mk;
#sed -i 's/ro.adb.secure=0/ro.adb.secure=1/' core/main.mk;

enterAndClear "device/qcom/sepolicy";
patch -p1 < $patches"android_device_qcom_sepolicy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH

enterAndClear "external/svox";
git revert 1419d63b4889a26d22443fd8df1f9073bf229d3d; #Add back Makefiles

enterAndClear "frameworks/base";
#git revert https://review.lineageos.org/#/c/202875/ #re-enable doze on devices without gms
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox
sed -i 's/com.android.messaging/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|config_permissionReviewRequired">false|config_permissionReviewRequired">true|' core/res/res/values/config.xml;
if [ "$MICROG_INCLUDED" = true ]; then patch -p1 < $patches"android_frameworks_base/0002-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$MICROG_INCLUDED" = true ]; then patch -p1 < $patches"android_frameworks_base/0003-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
if [ "$DEFAULT_DNS" = "Cloudflare" ]; then patch -p1 < $patches"android_frameworks_base/0004-DNS_Cloudflare.patch"; fi; #Switch to Cloudflare DNS
if [ "$DEFAULT_DNS" = "OpenNIC" ]; then patch -p1 < $patches"android_frameworks_base/0004-DNS_OpenNIC.patch"; fi; #Switch to OpenNIC DNS
#patch -p1 < $patches"android_frameworks_base/0005-Connectivity.patch"; #Change connectivity check URLs to ours
patch -p1 < $patches"android_frameworks_base/0006-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_frameworks_base/Copperhead/0005-Deny_USB.patch"; fi; #Deny USB support (Copperhead CC BY-NC-SA)
rm -rf packages/PrintRecommendationService; #App that just creates popups to install proprietary print apps
rm core/res/res/values/config.xml.orig core/res/res/values/strings.xml.orig;

#enterAndClear "frameworks/opt/net/ims";
#patch -p1 < $patches"android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling after we remove IMS

enterAndClear "frameworks/opt/net/wifi";
#Fix an issue when permision review is enabled that prevents using the Wi-Fi quick tile
#See https://github.com/CopperheadOS/platform_frameworks_opt_net_wifi/commit/c2a2f077a902226093b25c563e0117e923c7495b
sed -i 's/boolean mPermissionReviewRequired/boolean mPermissionReviewRequired = false/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/mPermissionReviewRequired = Build.PERMISSIONS_REVIEW_REQUIRED/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/\|\| context.getResources\(\).getBoolean\(/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/com.android.internal.R.bool.config_permissionReviewRequired/' service/java/com/android/server/wifi/WifiServiceImpl.java;

enterAndClear "lineage-sdk";
awk -i inplace '!/WeatherManagerServiceBroker/' lineage/res/res/values/config.xml; #Disable Weather
cp $patches"android_lineage-sdk/profile_default.xml" lineage/res/res/xml/profile_default.xml; #Replace default profiles with *way* better ones

if [ "$MICROG_INCLUDED" = true ]; then
enterAndClear "packages/apps/FakeStore";
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/ln -s /ln -sf /' Android.mk;
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;
fi;

enterAndClear "packages/apps/FDroid";
cp $patches"android_packages_apps_FDroid/default_repos.xml" app/src/main/res/values/default_repos.xml; #Add extra repos
sed -i 's|outputs/apk/|outputs/apk/release/|' Android.mk;
sed -i 's|gradle|./gradlew|' Android.mk; #Gradle 4.0 fix
sed -i 's|/$(fdroid_dir) \&\&| \&\&|' Android.mk; #One line wouldn't work... no matter what I tried.
sed -i 's/org\.fdroid\.fdroid/org.fdroid.fdroid_dos/' app/build.gradle; #Change the package ID until https://gitlab.com/fdroid/fdroidclient/issues/843 is implemented

enterAndClear "packages/apps/FDroidPrivilegedExtension";
sed -i 's/43238d512c1e5eb2d6569f4a3afbf5523418b82e0a3ed1552770abb9a9c9ccab/cb1ee2ec40d05ed678f42ae701cdfa29eea79d0e6d633276de230bf3494067c3/' app/src/main/java/org/fdroid/fdroid/privileged/ClientWhitelist.java;
sed -i 's/\"org\.fdroid\.fdroid/\"org.fdroid.fdroid_dos/' app/src/main/java/org/fdroid/fdroid/privileged/ClientWhitelist.java;
#release-key: CB:1E:E2:EC:40:D0:5E:D6:78:F4:2A:E7:01:CD:FA:29:EE:A7:9D:0E:6D:63:32:76:DE:23:0B:F3:49:40:67:C3
#test-key: C8:A2:E9:BC:CF:59:7C:2F:B6:DC:66:BE:E2:93:FC:13:F2:FC:47:EC:77:BC:6B:2B:0D:52:C1:1F:51:19:2A:B8

if [ "$MICROG_INCLUDED" = true ]; then
enterAndClear "packages/apps/GmsCore";
git submodule update --init --recursive;
fi;

if [ "$MICROG_INCLUDED" = true ]; then
enterAndClear "packages/apps/GsfProxy";
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;
fi;

enterAndClear "packages/apps/LineageParts";
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml #Nuke part of the analytics
sed -i 's|config_showWeatherMenu">true|config_showWeatherMenu">false|' res/values/config.xml; #Disable Weather
patch -p1 < $patches"android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics
rm AndroidManifest.xml.orig res/values/*.xml.orig;

enterAndClear "packages/apps/Settings";
git revert a96df110e84123fe1273bff54feca3b4ca484dcd; #don't hide oem unlock
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_packages_apps_Settings/Copperhead/0003-Deny_USB.patch"; fi; #Deny USB support (Copperhead CC BY-NC-SA)
patch -p1 < $patches"android_packages_apps_Settings/0004-PDB_Fixes.patch"; #Fix crashes when the PersistentDataBlockManager service isn't available
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/password/ChooseLockPassword.java; #Increase max password length
if [ "$MICROG_INCLUDED" = true ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options
rm res/values/strings.xml.orig;

enterAndClear "packages/apps/SetupWizard";
patch -p1 < $patches"android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics

enterAndClear "packages/apps/Trebuchet";
cp -r $patches"android_packages_apps_Trebuchet/default_workspace/." "res/xml/";

enterAndClear "packages/apps/Updater";
patch -p1 < $patches"android_packages_apps_Updater/0001-Server.patch"; #Switch to our server
#TODO: Remove changelog

enterAndClear "packages/apps/WallpaperPicker";
#TODO: Add back wallpapers
sed -i 's/req.touchEnabled = touchEnabled;/req.touchEnabled = true;/' src/com/android/wallpaperpicker/WallpaperCropActivity.java; #Allow scrolling
sed -i 's/mCropView.setTouchEnabled(req.touchEnabled);/mCropView.setTouchEnabled(true);/' src/com/android/wallpaperpicker/WallpaperCropActivity.java;
sed -i 's/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0);/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0.5f);/' src/com/android/wallpaperpicker/WallpaperPickerActivity.java; #Center aligned by default

enterAndClear "packages/inputmethods/LatinIME";
patch -p1 < $patches"android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key

enterAndClear "packages/services/Telephony";
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_packages_services_Telephony/Copperhead/0001-LTE_Only.patch"; fi; #LTE only preferred network mode choice (Copperhead CC BY-NC-SA)

enterAndClear "system/core";
cat /tmp/ar/hosts >> rootdir/etc/hosts; #Merge in our HOSTS file
git revert a6a4ce8e9a6d63014047a447c6bb3ac1fa90b3f4; #Always update recovery
patch -p1 < $patches"android_system_core/0001-Harden_Mounts.patch"; #Harden mounts with nodev/noexec/nosuid (CopperheadOS-13.0)
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_system_core/Copperhead/0002-Deny_USB.patch"; fi; #Deny USB support (Copperhead CC BY-NC-SA)
#if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_system_core/0003-Deny_USB-Aggressive.patch"; fi; #Deny USB on boot, may break things

enterAndClear "system/sepolicy";
patch -p1 < $patches"android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then patch -p1 < $patches"android_system_sepolicy/Copperhead/0002-Deny_USB.patch"; fi; #Deny USB support (Copperhead CC BY-NC-SA)

enterAndClear "system/vold";
patch -p1 < $patches"android_system_vold/0001-AES256.patch"; #Add a variable for enabling AES-256 bit encryption

enterAndClear "vendor/lineage";
rm -rf overlay/common/vendor/lineage-sdk/packages; #Remove analytics
if [ "$HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/common.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/common.mk; #Remove extra keys
awk -i inplace '!/security\/lineage/' config/common.mk; #Remove extra keys
sed -i '3iinclude vendor/lineage/config/sce.mk' config/common.mk; #Include extra apps
cp $patches"android_vendor_lineage/sce.mk" config/sce.mk;
if [ "$MICROG_INCLUDED" = true ]; then cp $patches"android_vendor_lineage/sce-microG.mk" config/sce-microG.mk; fi;
if [ "$MICROG_INCLUDED" = true ]; then echo "include vendor/lineage/config/sce-microG.mk" >> config/sce.mk; fi;
cp -r $patches"android_vendor_lineage/firmware_deblobber" .;
cp $patches"android_vendor_lineage/firmware_deblobber.mk" build/tasks/firmware_deblobber.mk;
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/common.mk; #Change buildtype
if [ "$NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/LINEAGE_BUILDTYPE := dos/LINEAGE_BUILDTYPE := dosNC/' config/common.mk; fi;
sed -i 's/messaging/Silence/' config/telephony.mk; #Replace AOSP Messaging app with Silence
#if [ "$HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += DNS66" >> config/sce.mk; fi; #Include DNS66 as an alternative
if [ "$HOSTS_BLOCKING" = false ]; then cp $patches"android_vendor_lineage/dns66.json" prebuilt/common/etc/dns66.json; fi;
if [ "$HOSTS_BLOCKING" = false ]; then sed -i '4iPRODUCT_COPY_FILES += vendor/lineage/prebuilt/common/etc/dns66.json:system/etc/dns66/settings.json' config/common.mk; fi; #Include DNS66 default config
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enterAndClear "device/lge/g2-common";
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;

enterAndClear "device/lge/g3-common";
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
sed -i '1itypeattribute wcnss_service misc_block_device_exception;' sepolicy/wcnss_service.te;
echo "allow wcnss_service block_device:dir search;" >> sepolicy/wcnss_service.te; #fix incorrect Wi-Fi MAC address
echo "/dev/block/platform/msm_sdcc\.1/by-name/pad     u:object_r:misc_block_device:s0" >> sepolicy/file_contexts; #fix uncrypt denial

enterAndClear "device/lge/mako";
cp $patches"android_device_lge_mako/proprietary-blobs.txt" proprietary-blobs.txt; #update that? nah
echo "allow kickstart usbfs:dir search;" >> sepolicy/kickstart.te; #Fix forceencrypt on first boot
patch -p1 < $patches"android_device_lge_mako/0001-Enable_LTE.patch";

enterAndClear "device/oppo/msm8974-common";
sed -i "s/TZ.BF.2.0-2.0.0134/TZ.BF.2.0-2.0.0134|TZ.BF.2.0-2.0.0137/" board-info.txt; #Suport new TZ firmware https://review.lineageos.org/#/c/178999/

#Make changes to all devices
cd $base;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enhanceLocation "$0"' {} \;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableDexPreOpt "$0"' {} \;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableForcedEncryption "$0"' {} \;
#if [ "$STRONG_ENCRYPTION_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableStrongEncryption "$0"' {} \; fi;
find "kernel" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenDefconfig "$0"' {} \;
cd $base;

#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/lge/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/motorola/msm8996/arch/arm64/configs/*_defconfig; #Breaks on compile
#
#END OF DEVICE CHANGES
#
