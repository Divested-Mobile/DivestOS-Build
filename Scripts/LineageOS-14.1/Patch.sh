#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2015-2020 Divested Computing Group
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

#Generate firmware deblobber
#mka firmware_deblobber

#
#START OF PREPRATION
#
#Download some (non-executable) out-of-tree files for use later on
cd "$DOS_TMP_DIR";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then $DOS_TOR_WRAPPER wget "$DOS_HOSTS_BLOCKING_LIST" -N -O "$DOS_HOSTS_FILE"; fi;
cd "$DOS_BUILD_BASE";
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

if enterAndClear "bionic"; then
patch -p1 < "$DOS_PATCHES_COMMON/android_bionic/0001-Wildcard_Hosts.patch"; #Support wildcards in cached hosts file (backport from 16.0+)
fi;

if enterAndClear "bootable/recovery"; then
git revert --no-edit 3c0d796b79c7a1ee904e0cef7c0f2e20bf84c237; #Remove sideload cache, breaks with large files
patch -p1 < "$DOS_PATCHES/android_bootable_recovery/0001-Squash_Menus.patch"; #What's a back button?
sed -i 's/(!has_serial_number || serial_number_matched)/!has_serial_number/' recovery.cpp; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build"; then
patch -p1 < "$DOS_PATCHES/android_build/0001-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification
sed -i '50i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
sed -i '296iLOCAL_AAPT_FLAGS += --auto-add-overlay' core/package_internal.mk;
sed -i 's/messaging/Silence/' target/product/aosp_base_telephony.mk; #Replace the Messaging app with Silence
sed -i 's/2021-06-05/2021-08-05/' core/version_defaults.mk; #Bump Security String to 2021-08-05 #n-asb-2021-08 #XXX
fi;

if enterAndClear "device/qcom/sepolicy"; then
patch -p1 < "$DOS_PATCHES/android_device_qcom_sepolicy/248649.patch"; #msm_irqbalance: Allow read for stats and interrupts
patch -p1 < "$DOS_PATCHES/android_device_qcom_sepolicy/0001-Camera_Fix.patch"; #Fix camera on user builds XXX: REMOVE THIS TRASH
fi;

if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then
if enterAndClear "external/chromium-webview"; then
DOS_WEBVIEW_CHERRYPICK; #Update the WebView to latest if available
fi;
fi;

if enterAndClear "external/sqlite"; then
patch -p1 < "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (AndroidHardening-13.0)
fi;

if enterAndClear "frameworks/av"; then
patch -p1 < "$DOS_PATCHES/android_frameworks_av/212799.patch"; #FLAC extractor CVE-2017-0592. alt: 212827/174106
fi;

if enterAndClear "frameworks/base"; then
hardenLocationFWB "$DOS_BUILD_BASE"; #Harden the default GPS config
git revert --no-edit 0326bb5e41219cf502727c3aa44ebf2daa19a5b3; #Re-enable doze on devices without gms
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
patch -p1 < "$DOS_PATCHES/android_frameworks_base/248599.patch"; #Make SET_TIME_ZONE permission match SET_TIME
patch -p1 < "$DOS_PATCHES/android_frameworks_base/0001-Reduced_Resolution.patch"; #Allow reducing resolution to save power TODO: Add 800x480
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0003-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0005-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
changeDefaultDNS; #Change the default DNS servers
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/0007-Connectivity.patch"; #Change connectivity check URLs to ours
patch -p1 < "$DOS_PATCHES/android_frameworks_base/0008-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries
patch -p1 < "$DOS_PATCHES_COMMON/android_frameworks_base/0001-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
patch -p1 < "$DOS_PATCHES_COMMON/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
rm -rf packages/Osu; #Automatic Wi-Fi connection non-sense
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
patch -p1 < "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed
fi;
fi;

if enterAndClear "frameworks/opt/net/wifi"; then
#Fix an issue when permision review is enabled that prevents using the Wi-Fi quick tile (AndroidHardening)
#See https://github.com/AndroidHardening/platform_frameworks_opt_net_wifi/commit/c2a2f077a902226093b25c563e0117e923c7495b
sed -i 's/boolean mPermissionReviewRequired/boolean mPermissionReviewRequired = false/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/mPermissionReviewRequired = Build.PERMISSIONS_REVIEW_REQUIRED/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/\|\| context.getResources\(\).getBoolean\(/' service/java/com/android/server/wifi/WifiServiceImpl.java;
awk -i inplace '!/com.android.internal.R.bool.config_permissionReviewRequired/' service/java/com/android/server/wifi/WifiServiceImpl.java;
fi;

if enterAndClear "hardware/ti/omap4"; then
patch -p1 < "$DOS_PATCHES/android_hardware_ti_omap4/0001-tuna-camera.patch"; #Fix camera on tuna
fi;

if enterAndClear "hardware/ti/wlan"; then
#krack fixes
git apply "$DOS_PATCHES/android_hardware_ti_wlan/209209.patch"; #wl12xx: Update SR and MR firmwares versions
git apply "$DOS_PATCHES/android_hardware_ti_wlan/209210.patch"; #wl12xx: Update SR PLT firmwares
fi;

if enterAndClear "hardware/qcom/display"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory msm8084;
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch" --directory msm8226;
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch" --directory msm8960;
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch" --directory msm8974;
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch" --directory msm8994;
#missing msm8909, msm8996, msm8998
git apply "$DOS_PATCHES/android_hardware_qcom_display/229952.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "hardware/qcom/display-caf/apq8084"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-apq8084.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8916"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8952"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8952.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8960"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8974"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8994"; then
git apply "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8996"; then
git apply "$DOS_PATCHES/android_hardware_qcom_display/227623.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "hardware/qcom/display-caf/msm8998"; then
git apply "$DOS_PATCHES/android_hardware_qcom_display/227624.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "hardware/qcom/gps"; then
git apply "$DOS_PATCHES/android_hardware_qcom_gps/0001-rollover.patch"; #Fix week rollover
fi;

if enterAndClear "hardware/qcom/media"; then
git apply "$DOS_PATCHES/android_hardware_qcom_media/229950.patch"; #n_asb_09-2018-qcom
git apply "$DOS_PATCHES/android_hardware_qcom_media/229951.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "hardware/qcom/media-caf/apq8084"; then
git apply "$DOS_PATCHES/android_hardware_qcom_media/227620.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "hardware/qcom/media-caf/msm8994"; then
git apply "$DOS_PATCHES/android_hardware_qcom_media/227622.patch"; #n_asb_09-2018-qcom
fi;

if enterAndClear "packages/apps/CMParts"; then
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_CMParts/0001-Remove_Analytics.patch"; #Remove the rest of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_CMParts/0002-Reduced_Resolution.patch"; #Allow reducing resolution to save power
fi;

if enterAndClear "packages/apps/PackageInstaller"; then
patch -p1 < "$DOS_PATCHES/android_packages_apps_PackageInstaller/64d8b44.diff"; #Fix an issue with Permission Review
fi;

if enterAndClear "packages/apps/Settings"; then
git revert --no-edit 2ebe6058c546194a301c1fd22963d6be4adbf961; #Don't hide OEM unlock
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/201113.patch"; #wifi: Add world regulatory domain country code
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options
fi;

if enterAndClear "packages/apps/SetupWizard"; then
patch -p1 < "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove the rest of CMStats
fi;

if enterAndClear "packages/apps/Updater"; then
patch -p1 < "$DOS_PATCHES_COMMON/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server
patch -p1 < "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support
#TODO: Remove changelog
fi;

if enterAndClear "packages/apps/WallpaperPicker"; then
rm res/drawable-nodpi/{*.png,*.jpg} res/values-nodpi/wallpapers.xml; #Remove old ones
cp -r "$DOS_WALLPAPERS"'Compressed/.' res/drawable-nodpi/; #Add ours
cp -r "$DOS_WALLPAPERS""Thumbs/." res/drawable-nodpi/;
cp "$DOS_WALLPAPERS""wallpapers.xml" res/values-nodpi/wallpapers.xml;
sed -i 's/req.touchEnabled = touchEnabled;/req.touchEnabled = true;/' src/com/android/wallpaperpicker/WallpaperCropActivity.java; #Allow scrolling
sed -i 's/mCropView.setTouchEnabled(req.touchEnabled);/mCropView.setTouchEnabled(true);/' src/com/android/wallpaperpicker/WallpaperCropActivity.java;
sed -i 's/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0);/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0.5f);/' src/com/android/wallpaperpicker/WallpaperPickerActivity.java; #Center aligned by default
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
patch -p1 < "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key
patch -p1 < "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/services/Telephony"; then
patch -p1 < "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch";
patch -p1 < "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch";
fi;

if enterAndClear "system/bt"; then
patch -p1 < "$DOS_PATCHES/android_system_bt/229574.patch"; #Increase maximum Bluetooth SBC codec bitrate for SBC HD
patch -p1 < "$DOS_PATCHES/android_system_bt/229575.patch"; #Explicit SBC Dual Channel (SBC HD) support
patch -p1 < "$DOS_PATCHES/android_system_bt/242134.patch"; #avrc_bld_get_attrs_rsp - fix attribute length position off by one
fi;

if enterAndClear "system/core"; then
sed -i 's/!= 2048/< 2048/' libmincrypt/tools/DumpPublicKey.java; #Allow 4096-bit keys
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 0217dddeb5c16903c13ff6c75213619b79ea622b d7aa1231b6a0631f506c0c23816f2cd81645b15f; #Always update recovery XXX: This doesn't seem to work
patch -p1 < "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/248600.patch"; #Restrict access to timing information in /proc
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices
fi;

if enterAndClear "system/vold"; then
patch -p1 < "$DOS_PATCHES/android_system_vold/0001-AES256.patch"; #Add a variable for enabling AES-256 bit encryption
fi;

if enterAndClear "vendor/cm"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/vendor/cmsdk/packages; #Remove analytics
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/common.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/common.mk; #Remove Lineage extra keys
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
	awk -i inplace '!/AudioFX/' config/common.mk; #Remove AudioFX
	awk -i inplace '!/AudioService/' config/common.mk;
fi;
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi; #Adjust the fused providers
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/CM_BUILDTYPE := dos/CM_BUILDTYPE := dosNC/' config/common.mk; fi;
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
sed -i 's/messaging/Silence/' config/telephony.mk; #Replace the Messaging app with Silence
fi;

if enterAndClear "vendor/cmsdk"; then
awk -i inplace '!/WeatherManagerServiceBroker/' cm/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/CMAudioService/' cm/res/res/values/config.xml; fi; #Remove AudioFX
sed -i 's/shouldUseOptimizations(weight)/true/' cm/lib/main/java/org/cyanogenmod/platform/internal/PerformanceManagerService.java; #Per app performance profiles fix
fi;

if enter "vendor/divested"; then
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> packages.mk; fi; #Include microG
if [ "$DOS_HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += $DOS_HOSTS_BLOCKING_APP" >> packages.mk; fi; #Include blocker app
sed -i 's/TalkBack/TalkBackLegacy/' packages.mk;
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/amazon/hdx-common"; then
sed -i 's/,encryptable=footer//' rootdir/etc/fstab.qcom; #Using footer will break the bootloader, it might work with /misc enabled
#XXX: If not used with a supported recovery, it'll be thrown into a bootloop, don't worry just 'fastboot erase misc' and reboot
#echo "/dev/block/platform/msm_sdcc.1/by-name/misc /misc emmc defaults defaults" >> rootdir/etc/fstab.qcom; #Add the misc (mmcblk0p5) partition for recovery flags
fi;

if enterAndClear "device/asus/grouper"; then
patch -p1 < "$DOS_PATCHES/android_device_asus_grouper/0001-Update_Blobs.patch";
patch -p1 < "$DOS_PATCHES/android_device_asus_grouper/0002-Perf_Tweaks.patch";
rm proprietary-blobs.txt;
cp "$DOS_PATCHES/android_device_asus_grouper/lineage-proprietary-files.txt" lineage-proprietary-files.txt;
echo "allow gpsd system_data_file:dir write;" >> sepolicy/gpsd.te;
fi;

if enterAndClear "device/htc/m7-common"; then
sed -i '38,$d' libshims/Android.mk; #Remove a breaking DRM shim
fi;

if enterAndClear "device/lge/g4-common"; then
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
fi;

if enterAndClear "device/motorola/clark"; then
sed -i 's/0xA04D/0xA04D|0xA052/' board-info.txt; #Allow installing on Nougat bootloader, assume the user is running the correct modem
rm board-info.txt; #Never restrict installation
fi;

if enterAndClear "device/samsung/exynos5420-common"; then
awk -i inplace '!/shell su/' sepolicy/shell.te; #neverallow
fi;

if enterAndClear "device/samsung/manta"; then
#git revert --no-edit e55bbff1c8aa50e25ffe39c8936ea3dc92a4a575; #restore releasetools #TODO
echo "allow audioserver sensorservice_service:service_manager find;" >> sepolicy/audioserver.te;
echo "allow mediacodec audio_device:chr_file getattr;" >> sepolicy/mediacodec.te;
echo "allow mediacodec camera_device:chr_file getattr;" >> sepolicy/mediacodec.te;
echo "allow mediacodec sysfs:file read;" >> sepolicy/mediacodec.te;
fi;

if enterAndClear "device/samsung/toroplus"; then
awk -i inplace '!/additional_system_update/' overlay/packages/apps/Settings/res/values*/*.xml;
fi;

if enterAndClear "device/samsung/tuna"; then
#git revert --no-edit e53eea6426da49dfb542929d5aa686667f4d416f; #restore releasetools #TODO
rm setup-makefiles.sh; #broken, deblobber will still function
sed -i 's|vendor/maguro/|vendor/|' libgps-shim/gps.c; #fix dlopen not found
#See: https://review.lineageos.org/q/topic:tuna-sepolicies
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0001-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0002-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0003-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0004-fix_denial.patch";
patch -p1 < "$DOS_PATCHES/android_device_samsung_tuna/0005-fix_denial.patch";
echo "allow system_server system_file:file execmod;" >> sepolicy/system_server.te; #fix gps load
fi;

if enter "vendor/google"; then
echo "" > atv/atv-common.mk;
fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
if [ "$DOS_LOWRAM_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableLowRam "{}"'; fi;
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi;
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenBootArgs "{}"';
if [ "$DOS_STRONG_ENCRYPTION_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableStrongEncryption "{}"'; fi;
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio;
removeBuildFingerprints;

#Tweaks for <2GB RAM devices
enableLowRam "device/asus/grouper";
enableLowRam "device/samsung/i9100";
enableLowRam "device/samsung/i9300";
enableLowRam "device/samsung/i9305";
enableLowRam "device/samsung/maguro";
enableLowRam "device/samsung/manta";
enableLowRam "device/samsung/toro";
enableLowRam "device/samsung/toroplus";

#Fixes
#Fix broken options enabled by hardenDefconfig()
sed -i "s/# CONFIG_KPROBES is not set/CONFIG_KPROBES=y/" kernel/amazon/hdx-common/arch/arm/configs/*hdx*_defconfig; #Breaks on compile
awk -i inplace '!/STACKPROTECTOR/' kernel/lge/msm8992/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_ARM_SMMU=y/# CONFIG_ARM_SMMU is not set/" kernel/motorola/msm8992/arch/arm64/configs/*defconfig; #Breaks on compile
#tuna fixes
awk -i inplace '!/nfc_enhanced.mk/' device/samsung/toro*/lineage.mk;
awk -i inplace '!/TARGET_RECOVERY_UPDATER_LIBS/' device/samsung/toro*/BoardConfig.mk;
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' device/samsung/toro*/BoardConfig.mk;

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l*; #Fix builds with GCC 10
#
#END OF DEVICE CHANGES
#
