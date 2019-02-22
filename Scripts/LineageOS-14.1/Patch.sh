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
#source ../../Scripts/init.sh

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
cd "$DOS_TMP_DIR";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then $DOS_TOR_WRAPPER wget "$DOS_HOSTS_BLOCKING_LIST" -N; fi;
cd "$DOS_BUILD_BASE";

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
cp -r "$DOS_PREBUILT_APPS""Fennec_DOS-Shim" "$DOS_BUILD_BASE""packages/apps/"; #Add a shim to install Fennec DOS without actually including the large APK
gpgVerifyDirectory "$DOS_PREBUILT_APPS""android_vendor_FDroid_PrebuiltApps/packages";
cp -r "$DOS_PREBUILT_APPS""android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE""vendor/fdroid_prebuilt/"; #Add the prebuilt apps
cp -r "$DOS_PATCHES_COMMON""android_vendor_divested/." "$DOS_BUILD_BASE""vendor/divested/"; #Add our vendor files

enterAndClear "bootable/recovery";
patch -p1 < "$DOS_PATCHES/android_bootable_recovery/0001-Squash_Menus.patch"; #What's a back button?

enterAndClear "build";
patch -p1 < "$DOS_PATCHES/android_build/0001-Automated_Build_Signing.patch"; #Automated build signing (CopperheadOS-13.0)
sed -i '50i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk;
sed -i '296iLOCAL_AAPT_FLAGS += --auto-add-overlay' core/package_internal.mk;

enterAndClear "device/qcom/sepolicy";
patch -p1 < "$DOS_PATCHES/android_device_qcom_sepolicy/0001-Camera_Fix.patch"; #Fix camera on user builds XXX: REMOVE THIS TRASH

enterAndClear "external/sqlite";
patch -p1 < "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (CopperheadOS-13.0)

enterAndClear "frameworks/base";
hardenLocationFWB "$DOS_BUILD_BASE";
git revert 0326bb5e41219cf502727c3aa44ebf2daa19a5b3; #re-enable doze on devices without gms
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify user when location is requested via SUPL
patch -p1 < "$DOS_PATCHES/android_frameworks_base/0001-Reduced_Resolution.patch"; #Allow reducing resolution to save power TODO: Add 800x480
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0003-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0005-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
changeDefaultDNS;
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/0007-Connectivity.patch"; #Change connectivity check URLs to ours
patch -p1 < "$DOS_PATCHES/android_frameworks_base/0008-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries
rm -rf packages/PrintRecommendationService; #App that just creates popups to install proprietary print apps

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
enterAndClear "frameworks/opt/net/ims";
patch -p1 < "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed
fi;

enterAndClear "frameworks/opt/net/wifi";
#Fix an issue when permision review is enabled that prevents using the Wi-Fi quick tile
#See https://github.com/CopperheadOS/platform_frameworks_opt_net_wifi/commit/c2a2f077a902226093b25c563e0117e923c7495b
sed -i 's/boolean mPermissionReviewRequired/boolean mPermissionReviewRequired = false/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/mPermissionReviewRequired = Build.PERMISSIONS_REVIEW_REQUIRED/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/\|\| context.getResources\(\).getBoolean\(/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/com.android.internal.R.bool.config_permissionReviewRequired/' service/java/com/android/server/wifi/WifiServiceImpl.java;

enterAndClear "hardware/ti/omap4";
patch -p1 < "$DOS_PATCHES/android_hardware_ti_omap4/0001-tuna-camera.patch"; #fix camera on tuna

enterAndClear "packages/apps/CMParts";
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_CMParts/0001-Remove_Analytics.patch"; #Remove the rest of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_CMParts/0002-Reduced_Resolution.patch"; #Allow reducing resolution to save power

enterAndClear "packages/apps/PackageInstaller";
patch -p1 < "$DOS_PATCHES/android_packages_apps_PackageInstaller/64d8b44.diff"; #Fix an issue with Permission Review

enterAndClear "packages/apps/Settings";
git revert 2ebe6058c546194a301c1fd22963d6be4adbf961; #don't hide oem unlock
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks, credit @MSe1969
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options

enterAndClear "packages/apps/SetupWizard";
patch -p1 < "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove the rest of CMStats

enterAndClear "packages/apps/Updater";
patch -p1 < "$DOS_PATCHES_COMMON/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server
patch -p1 < "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support
#TODO: Remove changelog

enterAndClear "packages/apps/WallpaperPicker";
rm res/drawable-nodpi/{*.png,*.jpg} res/values-nodpi/wallpapers.xml; #Remove old ones
cp -r "$DOS_WALLPAPERS"'Compressed/.' res/drawable-nodpi/; #Add ours
cp -r "$DOS_WALLPAPERS""Thumbs/." res/drawable-nodpi/;
cp "$DOS_WALLPAPERS""wallpapers.xml" res/values-nodpi/wallpapers.xml;
sed -i 's/req.touchEnabled = touchEnabled;/req.touchEnabled = true;/' src/com/android/wallpaperpicker/WallpaperCropActivity.java; #Allow scrolling
sed -i 's/mCropView.setTouchEnabled(req.touchEnabled);/mCropView.setTouchEnabled(true);/' src/com/android/wallpaperpicker/WallpaperCropActivity.java;
sed -i 's/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0);/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0.5f);/' src/com/android/wallpaperpicker/WallpaperPickerActivity.java; #Center aligned by default

enterAndClear "packages/inputmethods/LatinIME";
patch -p1 < "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key

enterAndClear "packages/services/Telephony";
patch -p1 < "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch";
patch -p1 < "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch";

enterAndClear "system/bt";
patch -p1 < "$DOS_PATCHES/android_system_bt/0001-Improve_Quality.patch"; #Improve Bluetooth audio quality, credit @ValdikSS

enterAndClear "system/core";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert 0217dddeb5c16903c13ff6c75213619b79ea622b d7aa1231b6a0631f506c0c23816f2cd81645b15f; #Always update recovery XXX: This doesn't seem to work
patch -p1 < "$DOS_PATCHES/android_system_core/0001-Harden_Mounts.patch"; #Harden mounts with nodev/noexec/nosuid (CopperheadOS-13.0)

enterAndClear "system/sepolicy";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices

enterAndClear "system/vold";
patch -p1 < "$DOS_PATCHES/android_system_vold/0001-AES256.patch"; #Add a variable for enabling AES-256 bit encryption

enterAndClear "vendor/cm";
rm -rf overlay/common/vendor/cmsdk/packages; #Remove analytics
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/common.mk; #Remove extra keys
awk -i inplace '!/security\/lineage/' config/common.mk; #Remove extra keys
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
	awk -i inplace '!/AudioFX/' config/common.mk;
	awk -i inplace '!/AudioService/' config/common.mk;
fi;
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi;
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/CM_BUILDTYPE := dos/CM_BUILDTYPE := dosNC/' config/common.mk; fi;
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations

enterAndClear "vendor/cmsdk";
awk -i inplace '!/WeatherManagerServiceBroker/' cm/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/CMAudioService/' cm/res/res/values/config.xml; fi;
sed -i 's/shouldUseOptimizations(weight)/true/' cm/lib/main/java/org/cyanogenmod/platform/internal/PerformanceManagerService.java; #Per app performance profiles fix

enter "vendor/divested";
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> packages.mk; fi;
if [ "$DOS_HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += $DOS_HOSTS_BLOCKING_APP" >> packages.mk; fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enterAndClear "device/amazon/hdx-common";
sed -i 's/,encryptable=footer//' rootdir/etc/fstab.qcom; #Using footer will break the bootloader, it might work with /misc enabled
#XXX: If not used with a supported recovery, it'll be thrown into a bootloop, don't worry just 'fastboot erase misc' and reboot
#echo "/dev/block/platform/msm_sdcc.1/by-name/misc /misc emmc defaults defaults" >> rootdir/etc/fstab.qcom; #Add the misc (mmcblk0p5) partition for recovery flags

enableLowRam "device/asus/grouper";
enterAndClear "device/asus/grouper";
patch -p1 < "$DOS_PATCHES/android_device_asus_grouper/0001-Update_Blobs.patch";
patch -p1 < "$DOS_PATCHES/android_device_asus_grouper/0002-Perf_Tweaks.patch";
rm proprietary-blobs.txt;
cp "$DOS_PATCHES/android_device_asus_grouper/lineage-proprietary-files.txt" lineage-proprietary-files.txt;

enterAndClear "device/lge/g2-common";
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;

enterAndClear "device/lge/g3-common";
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
sed -i '1itypeattribute wcnss_service misc_block_device_exception;' sepolicy/wcnss_service.te;
echo "allow wcnss_service block_device:dir search;" >> sepolicy/wcnss_service.te; #fix incorrect Wi-Fi MAC address

enterAndClear "device/lge/msm8996-common";
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;

enterAndClear "device/lge/mako";
echo "allow kickstart usbfs:dir search;" >> sepolicy/kickstart.te; #Fix forceencrypt on first boot

enterAndClear "device/motorola/clark";
sed -i 's/0xA04D/0xA04D|0xA052/' board-info.txt; #Allow installing on Nougat bootloader, assume the user is running the correct modem
rm board-info.txt; #Never restrict installation

enterAndClear "device/oneplus/bacon";
sed -i "s/TZ.BF.2.0-2.0.0134/TZ.BF.2.0-2.0.0134|TZ.BF.2.0-2.0.0137/" board-info.txt; #Suport new TZ firmware https://review.lineageos.org/#/c/178999/

enterAndClear "device/samsung/toroplus";
awk -i inplace '!/additional_system_update/' overlay/packages/apps/Settings/res/values*/*.xml;

enableLowRam "device/samsung/tuna";
enterAndClear "device/samsung/tuna";
rm setup-makefiles.sh; #broken, deblobber will still function
#See: https://review.lineageos.org/q/topic:%22tuna-sepolicies
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0001-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0002-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0003-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0004-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0005-fix_denial.patch";

enter "vendor/google";
echo "" > atv/atv-common.mk;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
if [ "$DOS_LOWRAM_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableLowRam "$0"' {} \;; fi;
find "hardware/qcom/gps" -name "gps\.conf" -type f -exec bash -c 'hardenLocationConf "$0"' {} \;;
find "device" -name "gps\.conf" -type f -exec bash -c 'hardenLocationConf "$0"' {} \;;
find "device" -type d -name "overlay" -exec bash -c 'hardenLocationFWB "$0"' {} \;;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableDexPreOpt "$0"' {} \;;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenUserdata "$0"' {} \;;
if [ "$DOS_STRONG_ENCRYPTION_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableStrongEncryption "$0"' {} \;; fi;
find "kernel" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenDefconfig "$0"' {} \;;
cd "$DOS_BUILD_BASE";

#Fixes
#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/lge/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/motorola/msm8974/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_ARM_SMMU=y/# CONFIG_ARM_SMMU is not set/" kernel/motorola/msm8992/arch/arm64/configs/*defconfig; #Breaks on compile
#tuna fixes
awk -i inplace '!/nfc_enhanced.mk/' device/samsung/toro*/lineage.mk;
awk -i inplace '!/TARGET_RECOVERY_UPDATER_LIBS/' device/samsung/toro*/BoardConfig.mk;
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' device/samsung/toro*/BoardConfig.mk;
sed -i "s/forceencrypt/encryptable/" device/samsung/tuna/rootdir/fstab.tuna; #first-boot encryption doesn't work
#
#END OF DEVICE CHANGES
#
