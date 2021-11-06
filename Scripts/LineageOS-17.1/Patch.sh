#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2015-2021 Divested Computing Group
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
set -euo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

#Last verified: 2021-10-16

#Initialize aliases
#source ../../Scripts/init.sh

#Delete Everything and Sync
#resetWorkspace

#Apply all of our changes
#patchWorkspace

#Build!
#buildDevice [device]
#buildAll

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
cp -r "$DOS_PREBUILT_APPS""SupportDivestOS" "$DOS_BUILD_BASE""packages/apps/"; #Add the Support app
gpgVerifyDirectory "$DOS_PREBUILT_APPS""android_vendor_FDroid_PrebuiltApps/packages";
cp -r "$DOS_PREBUILT_APPS""android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE""vendor/fdroid_prebuilt/"; #Add the prebuilt apps
cp -r "$DOS_PATCHES_COMMON""android_vendor_divested/." "$DOS_BUILD_BASE""vendor/divested/"; #Add our vendor files

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "bionic"; then
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0002-Symbol_Ordering.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit 0a9df01b268a238a623f5e0ea5221cebdfee2414; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Restore_TTS.patch"; #Add back PicoTTS and language files
applyPatch "$DOS_PATCHES/android_build/0002-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification
applyPatch "$DOS_PATCHES/android_build/0003-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
sed -i '75i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
sed -i 's/messaging/Silence/' target/product/aosp_base_telephony.mk target/product/gsi_common.mk; #Replace the Messaging app with Silence
awk -i inplace '!/updatable_apex.mk/' target/product/mainline_system.mk; #Disable APEX
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 23/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_defaults.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
fi;

if enterAndClear "device/qcom/sepolicy-legacy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy-legacy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH
echo "SELINUX_IGNORE_NEVERALLOWS := true" >> sepolicy.mk; #Ignore neverallow violations XXX: necessary for -user builds of legacy devices
fi;

if enterAndClear "external/chromium-webview"; then
if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then DOS_WEBVIEW_CHERRYPICK; fi; #Update the WebView to latest if available
if [ "$DOS_WEBVIEW_LFS" = true ]; then git lfs pull; fi; #Ensure the objects are available
fi;

if enterAndClear "external/svox"; then
git revert --no-edit 1419d63b4889a26d22443fd8df1f9073bf229d3d; #Add back Makefiles
sed -i '12iLOCAL_SDK_VERSION := current' pico/Android.mk; #Fix build under Pie
sed -i 's/about to delete/unable to delete/' pico/src/com/svox/pico/LangPackUninstaller.java;
awk -i inplace '!/deletePackage/' pico/src/com/svox/pico/LangPackUninstaller.java;
fi;

if enterAndClear "frameworks/av"; then
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_av/0001-HM_A2DP_Fix.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/0006-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0009-SystemUI_No_Permission_Review.patch"; #Allow SystemUI to directly manage Bluetooth/WiFi (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning.patch"; fi; #add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after three failed attempts (GrapheneOS)
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0011-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0012-Restore_SensorsOff.patch"; #Restore the Sensors Off tile
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Private_DNS.patch"; #More 'Private DNS' options (CalyxOS)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0002-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0003-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
hardenLocationConf services/core/java/com/android/server/location/gps_debug.conf; #Harden the default GPS config
changeDefaultDNS; #Change the default DNS servers
if [ "$DOS_MICROG_INCLUDED" != "FULL" ]; then rm -rf packages/CompanionDeviceManager; fi; #Used to support Android Wear (which hard depends on GMS)
#sed -i '295i\        if(packageList != null && packageList.size() > 0) { packageList.add("net.sourceforge.opencamera"); }' core/java/android/hardware/Camera.java; #Add Open Camera to aux camera allowlist XXX: needs testing, broke boot last time
rm -rf packages/OsuLogin; #Automatic Wi-Fi connection non-sense
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/native"; then
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed
fi;
fi;

if enterAndClear "hardware/qcom/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory="msm8084";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch" --directory="msm8226";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch" --directory="msm8960";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch" --directory="msm8974";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch" --directory="msm8994";
#TODO: missing msm8909, msm8996, msm8998, sdm845, sdm8150
fi;

if enterAndClear "hardware/qcom-caf/apq8084/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-apq8084.patch";
fi;

if enterAndClear "hardware/qcom-caf/msm8952/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8952.patch";
fi;

if enterAndClear "hardware/qcom-caf/msm8960/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch";
fi;

if enterAndClear "hardware/qcom-caf/msm8974/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch";
fi;

if enterAndClear "hardware/qcom-caf/msm8994/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch";
fi;

if enterAndClear "hardware/qcom-caf/msm8996/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8996.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "hardware/qcom-caf/msm8998/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8998.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "hardware/qcom-caf/sm8150/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "libcore"; then
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0001-Exec_Preload.patch"; fi; #Add exec-based spawning support (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0002-Exec_Based_Spawning.patch"; fi;
fi;

if enterAndClear "lineage-sdk"; then
awk -i inplace '!/LineageWeatherManagerService/' lineage/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0001-No_Google_Links.patch"; #Remove Privacy Policy and Terms of Service links (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0002-No_Google_Backup.patch"; #Backups are not sent to Google (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/0001-Not_Private_Banner.patch"; #Add a privacy warning banner to calls (CalyxOS)
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics
fi;

if enterAndClear "packages/apps/Settings"; then
git revert --no-edit 486980cfecce2ca64267f41462f9371486308e9d; #Don't hide OEM unlock
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0002-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0003-Remove_SensorsOff_Tile.patch"; #Remove the Sensors Off development tile
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (CalyxOS)
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/password/ChooseLockPassword.java; #Increase max password length (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/backup/PrivacySettingsUtils.java; fi; #microG doesn't support Backup, hide the options
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics
fi;

if enterAndClear "packages/apps/Trebuchet"; then
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support
sed -i 's/PROP_BUILD_VERSION_INCREMENTAL);/PROP_BUILD_VERSION_INCREMENTAL).replaceAll("\\\\.", "");/' src/org/lineageos/updater/misc/Utils.java; #Remove periods from incremental version
#TODO: Remove changelog
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

#if enterAndClear "packages/services/Telephony"; then
#applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch"; #XXX 17REBASE
#applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch"; #XXX 17REBASE
#fi;

if enterAndClear "system/core"; then
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 3032c7aa5ce90c0ae9c08fe271052c6e0304a1e7 01266f589e6deaef30b782531ae14435cdd2f18e; #insanity
git revert --no-edit bd4142eab8b3cead0c25a2e660b4b048d1315d3c; #Always update recovery
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0002-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
git am "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/29.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/28.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/27.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/26.0";
awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit c68499e3ff10f2a31f913e14f66aafb4ed94d42d; #Do not skip payload signature verification
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/*.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/WeatherProvider/' config/*.mk; #Remove Weather
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/AudioFX/' config/*.mk; fi; #Remove AudioFX
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi; #Adjust the fused providers
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/*.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/LINEAGE_BUILDTYPE := dos/LINEAGE_BUILDTYPE := dosNC/' config/*.mk; fi;
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
sed -i 's/messaging/Silence/' config/telephony.mk; #Replace the Messaging app with Silence
fi;

if enter "vendor/divested"; then
awk -i inplace '!/EtarPrebuilt/' packages.mk; #lineage-17.1 calendar is Etar fork
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> packages.mk; fi; #Include microG
if [ "$DOS_HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += $DOS_HOSTS_BLOCKING_APP" >> packages.mk; fi; #Include blocker app
echo "PRODUCT_PACKAGES += vendor.lineage.trust@1.0-service" >> packages.mk; #Add deny usb service, all of our kernels have the necessary patch
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/cyanogen/msm8916-common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #broken releasetools
fi;

if enterAndClear "device/google/bonito"; then
awk -i inplace '!/INODE_COUNT/' BoardConfig-lineage.mk; #mke2fs -1 incompatibility (?)
fi;

if enterAndClear "device/google/marlin"; then
git revert --no-edit 777dafa35f185b1f501e3c80b8ab495191583444; #remove some carrier blobs
sed -i 's/BTLogSave \\/BTLogSave/' common/base.mk; #deblobber fixup
fi;

if enterAndClear "device/htc/m8-common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #broken releasetools
fi;

if enterAndClear "device/motorola/clark"; then
echo "recovery_only(\`" >> sepolicy/recovery.te; #304224: Allow recovery to unzip and chmod modem firmware
echo "  allow firmware_file labeledfs:filesystem associate;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:dir rw_dir_perms;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:file create_file_perms;" >> sepolicy/recovery.te;
echo "')" >> sepolicy/recovery.te;
fi;

if enterAndClear "device/motorola/msm8916-common"; then
rm sepolicy/recovery.te;
echo "recovery_only(\`" >> sepolicy/recovery.te; #304224: Allow recovery to unzip and chmod modem firmware
echo "  allow firmware_file labeledfs:filesystem associate;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:dir rw_dir_perms;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:file create_file_perms;" >> sepolicy/recovery.te;
echo "')" >> sepolicy/recovery.te;
fi;

if enterAndClear "device/oneplus/oneplus2"; then
sed -i 's|etc/permissions/qti_libpermissions.xml|vendor/etc/permissions/qti_libpermissions.xml|' proprietary-files.txt;
echo "allow mm-qcamerad camera_data_file:file create_file_perms;" >> sepolicy/mm-qcamerad.te; #Likely some of these could be removed
echo "allow mm-qcamerad node:tcp_socket node_bind;" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad port:tcp_socket name_bind;" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad self:tcp_socket { accept listen };" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad self:tcp_socket { bind create setopt };" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad camera_prop:file read;" >> sepolicy/mm-qcamerad.te;
echo "set_prop(mm-qcamerad, camera_prop)" >> sepolicy/mm-qcamerad.te;
fi;

if enterAndClear "device/oppo/common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #disable releasetools to fix delta ota generation
fi;

if enterAndClear "device/zuk/msm8996-common"; then
awk -i inplace '!/WfdCommon/' msm8996.mk; #fix breakage
fi;

if enterAndClear "kernel/google/marlin"; then
git revert --no-edit dd4a454f080f60cc7c4f5cc281a48cba80947baf; #enable verity on /vendor
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
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableAPEX "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio;
removeBuildFingerprints;

#Tweaks for <2GB RAM devices
#enableLowRam "device/motorola/osprey";
#enableLowRam "device/motorola/surnia";

#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/yellowstone/arch/arm*/configs/*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/motorola/msm8996/arch/arm64/configs/*_defconfig; #Breaks on compile

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l*; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
