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

if enterAndClear "art"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_art/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "bionic"; then
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_BIONIC" = true ]; then
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-1.patch"; #Add a real explicit_bzero implementation (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-2.patch"; #Replace brk and sbrk with stubs (GrapheneOS) #XXX: some vendor blobs use sbrk
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-3.patch"; #Use blocking getrandom and avoid urandom fallback (GrapheneOS) #XXX: some kernels do not have (working) getrandom
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-4.patch"; #Fix undefined out-of-bounds accesses in sched.h (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-5.patch"; #Stop implicitly marking mappings as mergeable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-6.patch"; #Replace VLA formatting with dprintf-like function (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-7.patch"; #Increase default pthread stack to 8MiB on 64-bit (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-8.patch"; #Make __stack_chk_guard read-only at runtime (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-9.patch"; #On 64-bit, zero the leading stack canary byte (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-10.patch"; #Switch pthread_atfork handler allocation to mmap (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-11.patch"; #Add memory protection for pthread_atfork handlers (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-12.patch"; #Add XOR mangling mitigation for thread-local dtors (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-13.patch"; #Use a better pthread_attr junk filling pattern (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-14.patch"; #Add guard page(s) between static_tls and stack (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-15.patch"; #Move pthread_internal_t behind guard page (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-16.patch"; #Add secondary stack randomization (GrapheneOS)
fi;
fi;

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit def3f14af17ae92192d2cc7d22349cabfa906fd6; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES/android_build/0002-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_build/0003-Exec_Based_Spawning.patch"; fi; #Add exec-based spawning support (GrapheneOS)
sed -i '75i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
if [ "$DOS_SILENCE_INCLUDED" = true ]; then sed -i 's/messaging/Silence/' target/product/aosp_base_telephony.mk target/product/aosp_product.mk; fi; #Replace the Messaging app with Silence
awk -i inplace '!/updatable_apex.mk/' target/product/mainline_system.mk; #Disable APEX
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 23/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_defaults.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_build_soong/0002-hm_apex.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "device/qcom/sepolicy-legacy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy-legacy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH
echo "SELINUX_IGNORE_NEVERALLOWS := true" >> sepolicy.mk; #Ignore neverallow violations XXX: necessary for -user builds of legacy devices
fi;

if enterAndClear "external/chromium-webview"; then
if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then DOS_WEBVIEW_CHERRYPICK; fi; #Update the WebView to latest if available
if [ "$DOS_WEBVIEW_LFS" = true ]; then git lfs pull; fi; #Ensure the objects are available
fi;

if enterAndClear "external/conscrypt"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_external_conscrypt/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if [ "$DOS_GRAPHENE_MALLOC" = true ]; then
if enterAndClear "external/hardened_malloc"; then
applyPatch "$DOS_PATCHES/android_external_hardened_malloc/0001-Broken_Cameras.patch"; #Expand workaround to all camera executables
fi;
fi;

if enterAndClear "frameworks/base"; then
#applyPatch "$DOS_PATCHES/android_frameworks_base/0006-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0009-SystemUI_No_Permission_Review.patch"; #Allow SystemUI to directly manage Bluetooth/WiFi (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after three failed attempts (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0005-User_Logout.patch"; #Allow user logout (GrapheneOS)
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Sensors.patch"; fi #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0011-Restore_SensorsOff.patch"; #Restore the Sensors Off tile
applyPatch "$DOS_PATCHES/android_frameworks_base/0012-Private_DNS.patch"; #More 'Private DNS' options (CalyxOS)
if [ "$DOS_GRAPHENE_NETWORK_PERM" = true ]; then
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-1.patch"; #Expose the NETWORK permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-2.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-3.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-4.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-5.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-6.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-7.patch";
fi;
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0016-WiFi_Timeout.patch"; #Timeout for Wi-Fi (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0017-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-2.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-3.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-4.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-5.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-6.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-7.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-8.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-9.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-10.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-11.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-12.patch";
fi;
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0006-Do-not-throw-in-setAppOnInterfaceLocked.patch"; #Fix random reboots on broken kernels when an app has data restricted XXX: ugly
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0002-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0003-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
hardenLocationConf services/core/java/com/android/server/location/gps_debug.conf; #Harden the default GPS config
changeDefaultDNS; #Change the default DNS servers
#sed -i 's/DEFAULT_USE_COMPACTION = false;/DEFAULT_USE_COMPACTION = true;/' services/core/java/com/android/server/am/CachedAppOptimizer.java; #Enable app compaction by default (GrapheneOS)
#sed -i 's/DEFAULT_USE_FREEZER = false;/DEFAULT_USE_FREEZER = true;/' services/core/java/com/android/server/am/CachedAppOptimizer.java; #Enable app freezer by default (GrapheneOS)
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
#sed -i '301i\        if(packageList != null && packageList.size() > 0) { packageList.add("net.sourceforge.opencamera"); }' core/java/android/hardware/Camera.java; #Add Open Camera to aux camera allowlist XXX: needs testing, broke boot last time
if [ "$DOS_MICROG_INCLUDED" != "FULL" ]; then rm -rf packages/CompanionDeviceManager; fi; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/ex"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_ex/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "frameworks/native"; then
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_native/0002-fix-uaf.patch"; #Fix use-after-free in adbd_auth (GrapheneOS)
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

if enterAndClear "hardware/qcom-caf/sdm845/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sdm845.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "hardware/qcom-caf/sm8150/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "hardware/qcom-caf/sm8250/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c
fi;

if enterAndClear "libcore"; then
if [ "$DOS_GRAPHENE_NETWORK_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0001-Network_Permission.patch"; fi; #Expose the NETWORK permission (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0002-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-2.patch";
fi;
fi;

if enterAndClear "lineage-sdk"; then
awk -i inplace '!/LineageWeatherManagerService/' lineage/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Bluetooth"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
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

if enterAndClear "packages/apps/Nfc"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/PermissionController"; then
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0001-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_GRAPHENE_NETWORK_PERM" = true ]; then
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0002-Network_Permission-1.patch"; #Expose the NETWORK permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0002-Network_Permission-2.patch";
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0002-Network_Permission-3.patch";
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0002-Network_Permission-4.patch";
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0002-Network_Permission-5.patch";
fi;
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
if [ "$DOS_SENSORS_PERM_NEW" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0002-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0003-Remove_SensorsOff_Tile.patch"; #Remove the Sensors Off development tile
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0006-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0007-WiFi_Timeout.patch"; #Timeout for Wi-Fi (CalyxOS)
if [ "$DOS_GRAPHENE_PTRACE_SCOPE" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0008-ptrace_scope.patch"; fi; #Add native debugging setting (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0009-Install_Restrictions.patch"; #UserManager app installation restrictions (GrapheneOS)
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

if enterAndClear "packages/providers/DownloadProvider"; then
if [ "$DOS_GRAPHENE_NETWORK_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; fi; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "packages/providers/TelephonyProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/304614.patch"; #mcc/mnc fix
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/312102.patch"; #mnc fix
fi;

#if enterAndClear "packages/services/Telephony"; then
#applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch"; #XXX 18REBASE
#applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch"; #XXX 18REBASE
#fi;

if enterAndClear "system/bt"; then
git am "$DOS_PATCHES/android_system_bt/a2dp-master-fixes.patch"; #topic
applyPatch "$DOS_PATCHES_COMMON/android_system_bt/0001-alloc_size.patch"; #Add alloc_size attributes to the allocator (GrapheneOS)
fi;

if enterAndClear "system/core"; then
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit e8dcabaf6b55ec55eb73c4585501ddbafc04fc9b 79f606ece6b74652d374eb4f79de309a0aa81360; #insanity
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
if [ "$DOS_GRAPHENE_PTRACE_SCOPE" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0002-ptrace_scope.patch"; fi; #Add a property for controlling ptrace_scope (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0003-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_BIONIC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0004-Zero_Sensitive_Info.patch"; fi; #Zero sensitive information with explicit_bzero (GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/netd"; then
if [ "$DOS_GRAPHENE_NETWORK_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_system_netd/0001-Network_Permission.patch"; fi; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #Label protected_{fifos,regular} as proc_security (GrapheneOS)
if [ "$DOS_GRAPHENE_PTRACE_SCOPE" = true ]; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
fi;
git am "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/30.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/29.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/28.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/27.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/26.0";
awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit c0e056ed5c084ce55557c4aecbad540e2b235785; #Do not skip payload signature verification
fi;

if enterAndClear "system/vold"; then
git revert --no-edit 3461ff5c9ad334c96780f3da14f1d23fcbee63ad; #breaks mako first boot
fi;

if enterAndClear "vendor/lineage"; then
rm overlay/common/frameworks/base/core/res/res/xml/config_webview_packages.xml; #Use the WebView overlay in vendor_divested instead
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/*.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/WeatherProvider/' config/*.mk; #Remove Weather
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then sed -i '25d' config/common_mobile.mk && awk -i inplace '!/AudioFX/' config/*.mk; fi; #Remove AudioFX #XXX: 18REBASE
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi; #Adjust the fused providers
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/*.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/LINEAGE_BUILDTYPE := dos/LINEAGE_BUILDTYPE := dosNC/' config/*.mk; fi;
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
if [ "$DOS_SILENCE_INCLUDED" = true ]; then sed -i 's/messaging/Silence/' config/telephony.mk; fi; #Replace the Messaging app with Silence
awk -i inplace '!/Eleven/' config/common_mobile.mk; #Remove Music Player
awk -i inplace '!/Email/' config/common_mobile.mk; #Remove Email
awk -i inplace '!/Exchange2/' config/common_mobile.mk;
fi;

if enter "vendor/divested"; then
awk -i inplace '!/_lookup/' overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove all lookup provider overrides
if [ "$DOS_MICROG_INCLUDED" != "NONE" ]; then echo "PRODUCT_PACKAGES += DejaVuNlpBackend IchnaeaNlpBackend NominatimNlpBackend" >> packages.mk; fi; #Include UnifiedNlp backends
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then echo "PRODUCT_PACKAGES += UnifiedNLP" >> packages.mk; fi; #Include UnifiedNlp
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> packages.mk; fi; #Include microG
if [ "$DOS_HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += $DOS_HOSTS_BLOCKING_APP" >> packages.mk; fi; #Include blocker app
echo "PRODUCT_PACKAGES += vendor.lineage.trust@1.0-service" >> packages.mk; #Add deny usb service, all of our kernels have the necessary patch
echo "PRODUCT_PACKAGES += eSpeakNG" >> packages.mk; #PicoTTS needs work to compile on 18.1, use eSpeak-NG instead
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/asus/flox"; then
compressRamdisks;
echo "allow camera system_data_root_file:dir rw_dir_perms;" >> sepolicy/vendor/camera.te; #Fixup camera
echo "allow camera system_data_root_file:sock_file { create unlink write setattr };" >> sepolicy/vendor/camera.te;
echo "allow cameraserver sysfs_soc:dir r_dir_perms;" >> sepolicy/vendor/cameraserver.te;
echo "allow cameraserver sysfs_soc:file r_file_perms;" >> sepolicy/vendor/cameraserver.te;
fi;

if enterAndClear "device/essential/mata"; then
#git revert --no-edit 1f1d061c4d7ddedcac503608e8fa333aff30a693 3928b30a97fe7f6b6020bbd9d83a56a32de4ba16 e91f0fece65d32ca407be532e2c4456056b1a968; #Unbreak the earpiece speaker, breaking the loud speaker volume control on calls
echo "allow permissioncontroller_app tethering_service:service_manager find;" > sepolicy/private/permissioncontroller_app.te;
fi;

if enterAndClear "device/google/bonito"; then
awk -i inplace '!/INODE_COUNT/' BoardConfigLineage.mk; #mke2fs -1 incompatibility (?)
fi;

if enterAndClear "device/google/marlin"; then
sed -i 's/BTLogSave \\/BTLogSave/' common/base.mk; #deblobber fixup
fi;

if enterAndClear "device/google/redbull"; then
awk -i inplace '!/sctp/' BoardConfig-common.mk modules.load; #fix compile after hardenDefconfig
fi;

if enterAndClear "device/htc/m8-common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #broken releasetools
fi;

if enterAndClear "device/htc/msm8974-common"; then
applyPatch "$DOS_PATCHES/android_device_htc_msm8974-common/295147.patch"; #Enable ZRAM
fi;

if enterAndClear "device/lge/g2-common"; then
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
echo "allow hwaddrs self:capability { fowner };" >> sepolicy/hwaddrs.te;
echo "allow hwaddrs block_device:lnk_file { open };" >> sepolicy/hwaddrs.te;
echo "allow hwaddrs misc_block_device:blk_file { open read };" >> sepolicy/hwaddrs.te;
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #broken releasetools
fi;

if enterAndClear "device/lge/g3-common"; then
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
echo "allow hwaddrs self:capability { fowner };" >> sepolicy/hwaddrs.te;
echo "allow hwaddrs block_device:lnk_file { open };" >> sepolicy/hwaddrs.te;
echo "allow hwaddrs misc_block_device:blk_file { open read };" >> sepolicy/hwaddrs.te;
sed -i '1itypeattribute wcnss_service misc_block_device_exception;' sepolicy/wcnss_service.te;
fi;

if enterAndClear "device/lge/mako"; then
git revert --no-edit 4d779eb8e653640f192878f3f666cb54ea65bf47;
applyPatch "$DOS_PATCHES/android_device_lge_mako/0001-LTE.patch"; #Enable LTE support #TODO: rebase
rm overlay/packages/apps/CarrierConfig/res/xml/vendor.xml;
echo "pmf=0" >> wifi/wpa_supplicant_overlay.conf; #Wi-Fi chipset doesn't support PMF
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfig.mk; #broken releasetools
sed -i 's/bdAddrLoader/bdAddrLoader-mako/' device.mk bdAddrLoader/Android.bp bdAddrLoader/addrloader.c rootdir/etc/init.mako.bt.sh sepolicy/vendor/file_contexts; #Fix conflicts
sed -i 's|/bdAddrLoader|/bdAddrLoader-mako|' rootdir/etc/init.mako.rc;
sed -i '16iifeq ($(TARGET_DEVICE),mako)' sensors/Android.mk;
echo "endif" >> sensors/Android.mk;
fi;

if enterAndClear "device/lge/msm8996-common"; then
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
echo "allow hwaddrs self:capability { fowner };" >> sepolicy/hwaddrs.te;
echo "allow hwaddrs block_device:lnk_file { open };" >> sepolicy/hwaddrs.te;
awk -i inplace '!/WfdCommon/' msm8996.mk; #fix breakage
echo "type sensors_data_file, file_type, data_file_type, core_data_file_type;" >> sepolicy/file.te; #only included in -userdebug
fi;

if enterAndClear "device/moto/shamu"; then
git revert --no-edit 0ba2cb240e8483fa85fcc831328f70f65eeb7180 2be3c88c331387f03978b75ebc118e09738216d0 ff98fee8fc40d00e1c8b296fd4bb20077bc056d6; #breakage
#git revert --no-edit 05fb49518049440f90423341ff25d4f75f10bc0c; #restore releasetools #TODO
fi;

if enterAndClear "device/oneplus/msm8998-common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #disable releasetools to fix delta ota generation
sed -i '/PRODUCT_SYSTEM_VERITY_PARTITION/iPRODUCT_VENDOR_VERITY_PARTITION := /dev/block/bootdevice/by-name/vendor' common.mk; #Support verity on /vendor too
awk -i inplace '!/vendor_sensors_dbg_prop/' sepolicy/vendor/hal_camera_default.te; #fixup
fi;

if enterAndClear "device/oppo/common"; then
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #disable releasetools to fix delta ota generation
fi;

if enterAndClear "device/oppo/msm8974-common"; then
sed -i 's/libinit_msm8974/libinit_msm8974-oppo/' BoardConfigCommon.mk init/Android.bp; #Fix name conflict
sed -i "s/TZ.BF.2.0-2.0.0134/TZ.BF.2.0-2.0.0134|TZ.BF.2.0-2.0.0137/" board-info.txt; #Suport new TZ firmware https://review.lineageos.org/#/c/178999/
fi;

if enterAndClear "device/samsung/jfltexx"; then
smallerSystem;
fi;

if enterAndClear "device/samsung/msm8974-common"; then
echo "TARGET_RECOVERY_DENSITY := hdpi" >> BoardConfigCommon.mk;
echo "allow hal_gnss_default ssr_device:chr_file { open read };" >> sepolicy/common/hal_gnss_default.te;
fi;

if enterAndClear "device/zuk/msm8996-common"; then
awk -i inplace '!/WfdCommon/' msm8996.mk; #fix breakage
fi;

if enterAndClear "kernel/google/marlin"; then
git revert --no-edit a17f0cc9d8f16df52d3cf3ff64b37bf477f589e5; #enable verity on /vendor
fi;

if enterAndClear "kernel/google/wahoo"; then
sed -i 's/asm(SET_PSTATE_UAO(1));/asm(SET_PSTATE_UAO(1)); return 0;/' arch/arm64/mm/fault.c; #fix build with CONFIG_ARM64_UAO
fi;

if enterAndClear "kernel/oneplus/sdm845"; then
applyPatch "$DOS_PATCHES/android_kernel_oneplus_sdm845/4.9.282-qc.patch"; #4.9.227 -> 4.9.282
fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
if [ "$DOS_LOWRAM_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableLowRam "{}"'; fi;
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
#find "device" -name "WCNSS_qcom_cfg.\ini" -type f -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'extremeWiFiDeepSleep "{}"';
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
#enableLowRam "device/samsung/serrano3gxx";
#enableLowRam "device/samsung/serranoltexx";

#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/lge/mako/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/lge/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/motorola/msm8974/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/oneplus/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l*; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
