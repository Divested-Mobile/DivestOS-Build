#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2015-2022 Divested Computing Group
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

#Last verified: 2022-04-05

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
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-10.patch"; #Switch pthread_atfork handler allocation to mmap (GrapheneOS) #XXX: patches from here on are known to cause boot issues on legacy devices
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-11.patch"; #Add memory protection for pthread_atfork handlers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-12.patch"; #Add XOR mangling mitigation for thread-local dtors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-13.patch"; #Use a better pthread_attr junk filling pattern (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-14.patch"; #Add guard page(s) between static_tls and stack (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-15.patch"; #Move pthread_internal_t behind guard page (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-16.patch"; #Add secondary stack randomization (GrapheneOS)
fi;
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Cache.patch"; #Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Wildcards.patch"; #Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0004-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit 7f4b9a43f3c49a5a896dd4951be0a96584751f46; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES/android_build/0002-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_build/0003-Exec_Based_Spawning.patch"; fi; #Add exec-based spawning support (GrapheneOS) #XXX: most devices override this
sed -i '75i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
awk -i inplace '!/updatable_apex.mk/' target/product/generic_system.mk; #Disable APEX
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 23/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_defaults.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
#sed -i 's/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := true/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false/' core/product_config.mk; #broken by hardenDefconfig
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_build_soong/0002-hm_apex.patch"; fi; #(GrapheneOS)
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
applyPatch "$DOS_PATCHES/android_external_hardened_malloc/0001-Broken_Cameras-1.patch"; #Workarounds for Pixel 3 SoC era camera driver bugs (GrapheneOS)
applyPatch "$DOS_PATCHES/android_external_hardened_malloc/0001-Broken_Cameras-2.patch"; #Expand workaround to all camera executables (DivestOS)
fi;
fi;

if enterAndClear "external/SecureCamera"; then
sed -i '/LOCAL_MODULE/s/Camera/SecureCamera/' Android.mk; #Change module name
sed -i '11iLOCAL_OVERRIDES_PACKAGES := Camera Camera2 LegacyCamera Snap OpenCamera' Android.mk; #Replace the others
fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/344888-backport.patch"; #fixup! fw/b: Add support for allowing/disallowing apps on cellular, vpn and wifi networks (CalyxOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0009-SystemUI_No_Permission_Review.patch"; #Allow SystemUI to directly manage Bluetooth/WiFi (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after three failed attempts (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0005-User_Logout.patch"; #Allow user logout (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions.patch"; #Support new special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-2.patch"; #Extend special runtime permission implementation (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-1.patch"; #Make INTERNET into a special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-2.patch"; #Add a NETWORK permission group for INTERNET (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-3.patch"; #net: Notify ConnectivityService of runtime permission changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-4.patch"; #Make DownloadManager.enqueue() a no-op when INTERNET permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-5.patch"; #Make DownloadManager.query() a no-op when INTERNET permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Sensors_Permission.patch"; #Add special runtime permission for other sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0016-WiFi_Timeout.patch"; #Timeout for Wi-Fi (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0017-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-2.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-3.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-4.patch";
#applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-5.patch"; #XXX: reverted upstream
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-6.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-7.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-8.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-9.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-10.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-11.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-12.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-13.patch";
sed -i 's/sys.spawn.exec/persist.security.exec_spawn_new/' core/java/com/android/internal/os/ZygoteConnection.java;
fi;
applyPatch "$DOS_PATCHES/android_frameworks_base/0020-Location_Indicators.patch"; #SystemUI: Use new privacy indicators for location (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0021-Boot_Animation.patch"; #Use basic boot animation (DivestOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0022-Ignore_StatementService_ANR.patch"; #Don't report statementservice crashes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/326692.patch"; #Skip screen on animation when wake and unlock via biometrics (jesec)
applyPatch "$DOS_PATCHES/android_frameworks_base/0023-Skip_Screen_Animation.patch"; #SystemUI: Skip screen-on animation in all scenarios (kdrag0n)
applyPatch "$DOS_PATCHES/android_frameworks_base/0024-Burnin_Protection.patch"; #SystemUI: add burnIn protection (arter97)
applyPatch "$DOS_PATCHES/android_frameworks_base/0025-Monet_Toggle.patch"; #Make monet based theming user configurable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0026-Crash_Details.patch"; #Add an option to show the details of an application error to the user (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0007-ABI_Warning.patch"; #Warn when running activity from 32 bit app on ARM64 devices. (AOSP)
hardenLocationConf services/core/java/com/android/server/location/gnss/gps_debug.conf; #Harden the default GPS config
changeDefaultDNS; #Change the default DNS servers
sed -i 's/DEFAULT_USE_COMPACTION = false;/DEFAULT_USE_COMPACTION = true;/' services/core/java/com/android/server/am/CachedAppOptimizer.java; #Enable app compaction by default (GrapheneOS)
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/MAX_PASSWORD_LENGTH = 16/MAX_PASSWORD_LENGTH = 64/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
#sed -i '282i\        if(packageList != null && packageList.size() > 0) { packageList.add("net.sourceforge.opencamera"); }' core/java/android/hardware/Camera.java; #Add Open Camera to aux camera allowlist XXX: needs testing, broke boot last time
rm -rf packages/CompanionDeviceManager; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/ex"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_ex/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "frameworks/libs/net"; then
applyPatch "$DOS_PATCHES/android_frameworks_libs_net/0001-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
fi;

if enterAndClear "frameworks/libs/systemui"; then
applyPatch "$DOS_PATCHES/android_frameworks_libs_systemui/0001-Icon_Cache.patch"; #Invalidate icon cache between OS releases (GrapheneOS)
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors_Permission.patch"; #Require OTHER_SENSORS permission for sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors_Permission-a1.patch"; #Protect step sensors with OTHER_SENSORS permission for targetSdk<29 apps (GrapheneOS)
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed (DivestOS)
fi;
fi;

if enterAndClear "frameworks/opt/net/wifi"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/0001-Random_MAC.patch"; #Add support for always generating new random MAC (GrapheneOS)
fi;

if enterAndClear "hardware/qcom-caf/msm8953/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8998.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/msm8998/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8998.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/sdm845/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sdm845.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/sm8150/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/sm8250/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/sm8350/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "libcore"; then
applyPatch "$DOS_PATCHES/android_libcore/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0002-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-2.patch";
fi;
fi;

if enterAndClear "lineage-sdk"; then
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Bluetooth"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

#if enterAndClear "packages/apps/CarrierConfig"; then
#rm -rf assets/*.xml;
#cp $DOS_PATCHES_COMMON/android_packages_apps_CarrierConfig/*.xml assets/;
#fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0001-No_Google_Links.patch"; #Remove Privacy Policy and Terms of Service links (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0002-No_Google_Backup.patch"; #Backups are not sent to Google (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0003-Skip_Accounts.patch"; #Don't prompt to add account when creating a contact (CalyxOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0004-No_GMaps.patch"; #Use common intent for directions instead of Google Maps URL (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/0001-Not_Private_Banner.patch"; #Add a privacy warning banner to calls (CalyxOS)
sed -i 's/>true/>false/' java/com/android/incallui/res/values/lineage_config.xml; #XXX: temporary workaround for black screen on incoming calls https://gitlab.com/LineageOS/issues/android/-/issues/4632
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Nfc"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0006-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0007-WiFi_Timeout.patch"; #Timeout for Wi-Fi (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0008-ptrace_scope.patch"; #Add native debugging setting (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0010-exec_spawning_toggle.patch"; fi; #Add exec spawning toggle (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0011-Random_MAC.patch"; #Add option to always randomize MAC (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0009-Install_Restrictions.patch"; #UserManager app installation restrictions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0012-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0013-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/ThemePicker"; then
applyPatch "$DOS_PATCHES/android_packages_apps_ThemePicker/0001-Monet_Toggle.patch"; #Add a UI for enabling Material You (GrapheneOS)
fi;

if enterAndClear "packages/apps/Trebuchet"; then
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
sed -i 's/PROP_BUILD_VERSION_INCREMENTAL);/PROP_BUILD_VERSION_INCREMENTAL).replaceAll("\\\\.", "");/' src/org/lineageos/updater/misc/Utils.java; #Remove periods from incremental version
#TODO: Remove changelog
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/modules/Connectivity"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-1.patch"; #Add callback for enforcing INTERNET permission changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-2.patch"; #Use uid instead of app id (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-3.patch"; #Skip reportNetworkConnectivity() when permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0002-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
fi;

if enterAndClear "packages/modules/DnsResolver"; then
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Cache.patch"; #DnsResolver: Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Wildcards.patch"; #DnsResolver: Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0002-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "packages/modules/NetworkStack"; then
applyPatch "$DOS_PATCHES/android_packages_modules_NetworkStack/0001-Random_MAC.patch"; #Avoid reusing DHCP state for full MAC randomization (GrapheneOS)
fi;

if enterAndClear "packages/modules/Permission"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0002-Network_Permission-1.patch"; #Always treat INTERNET as a runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0002-Network_Permission-2.patch"; #Add INTERNET permission toggle (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0003-Sensors_Permission-1.patch"; #Always treat OTHER_SENSORS as a runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0003-Sensors_Permission-2.patch"; #Add OTHER_SENSORS permission group (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permission-1.patch"; #Refactor handling of special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permission-2.patch"; #Don't auto revoke Network and Sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permission-3.patch"; #UI fix for special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permission-4.patch"; #Fix usage UI summary for Network/Sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0005-Browser_No_Location.patch"; #Stop auto-granting location to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0006-Location_Indicators.patch"; #SystemUI: Use new privacy indicators for location (GrapheneOS)
fi;

if enterAndClear "packages/modules/Wifi"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/0001-Random_MAC.patch"; #Add support for always generating new random MAC (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/0001-Random_MAC-a1.patch"; #Fix MAC address leak after SSR (AOSP)
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/0001-Random_MAC-a2.patch"; #WifiService: Capture BackendBusyException in MacRandomization (CodeAurora)
fi;

if enterAndClear "packages/providers/DownloadProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

#if enterAndClear "packages/providers/TelephonyProvider"; then
#cp $DOS_PATCHES_COMMON/android_packages_providers_TelephonyProvider/carrier_list.* assets/latest_carrier_id/;
#fi;

if enterAndClear "system/bt"; then
applyPatch "$DOS_PATCHES_COMMON/android_system_bt/0001-alloc_size.patch"; #Add alloc_size attributes to the allocator (GrapheneOS)
fi;

if enterAndClear "system/core"; then
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 07adb89d0f8c966c88869d1abffc57da0e707568; #insanity
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0002-ptrace_scope.patch"; #Add a property for controlling ptrace_scope (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0003-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/netd"; then
applyPatch "$DOS_PATCHES/android_system_netd/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #Label protected_{fifos,regular} as proc_security (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
awk -i inplace '!/domain=gmscore_app/' private/seapp_contexts prebuilts/api/*/private/seapp_contexts; #Disable unused gmscore_app domain (GrapheneOS)
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit a5a18ac5e2a2377fe036fcae93548967a7b40470; #Do not skip payload signature verification
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
rm -rf overlay/common/packages/modules/NetworkStack/res/values/config.xml; #Do not set device model as DHCP hostname
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/*.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then sed -i '20d' config/common_mobile.mk && awk -i inplace '!/AudioFX/' config/*.mk; fi; #Remove AudioFX
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/*.mk; #Change buildtype
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
awk -i inplace '!/Eleven/' config/common_mobile.mk; #Remove Music Player
fi;

if enter "vendor/divested"; then
awk -i inplace '!/_lookup/' overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove all lookup provider overrides
echo "PRODUCT_PACKAGES += vendor.lineage.trust@1.0-service" >> packages.mk; #Add deny usb service, all of our kernels have the necessary patch
echo "PRODUCT_PACKAGES += eSpeakNG" >> packages.mk; #PicoTTS needs work to compile on 18.1, use eSpeak-NG instead
sed -i 's/OpenCamera/SecureCamera/' packages.mk #Use the GrapheneOS camera app
awk -i inplace '!/speed-profile/' build/target/product/lowram.mk; #breaks compile on some dexpreopt devices
sed -i 's/wifi,cell/internet/' overlay/common/frameworks/base/packages/SystemUI/res/values/config.xml; #Use the modern quick tile
sed -i 's|system/etc|$(TARGET_COPY_OUT_PRODUCT)/etc|' divestos.mk;
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/essential/mata"; then
echo "allow permissioncontroller_app tethering_service:service_manager find;" > sepolicy/private/permissioncontroller_app.te;
fi;

if enterAndClear "device/oneplus/msm8998-common"; then
#awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #disable releasetools to fix delta ota generation
sed -i '/PRODUCT_SYSTEM_VERITY_PARTITION/iPRODUCT_VENDOR_VERITY_PARTITION := /dev/block/bootdevice/by-name/vendor' common.mk; #Support verity on /vendor too
awk -i inplace '!/vendor_sensors_dbg_prop/' sepolicy/vendor/hal_camera_default.te; #fixup
fi;

if enterAndClear "hardware/oplus"; then
echo "allow update_engine_common vendor_custom_ab_block_device:blk_file rw_file_perms;" >> sepolicy/qti/vendor/update_engine_common.te; #fix firmware flash
fi;

if enterAndClear "kernel/fairphone/sdm632"; then
sed -i 's|/../../prebuilts/tools-lineage|/../../../prebuilts/tools-lineage|' lib/Makefile; #fixup typo
fi;

if enterAndClear "kernel/google/wahoo"; then
sed -i 's/asm(SET_PSTATE_UAO(1));/asm(SET_PSTATE_UAO(1)); return 0;/' arch/arm64/mm/fault.c; #fix build with CONFIG_ARM64_UAO
fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi;
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableAPEX "{}"';
if [ "$DOS_GRAPHENE_EXEC" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableEnforceRRO "{}"'; fi;
cd "$DOS_BUILD_BASE";
deblobAudio || true;
removeBuildFingerprints || true;
enableAutoVarInit || true;
cd "$DOS_BUILD_BASE";
#rm -rfv device/*/*/overlay/CarrierConfigResCommon device/*/*/rro_overlays/CarrierConfigOverlay device/*/*/overlay/packages/apps/CarrierConfig/res/xml/vendor.xml;

#Tweaks for <4GB RAM devices
#enableLowRam "device/sony/pioneer" "pioneer";

#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_PREEMPT_TRACER=n/CONFIG_PREEMPT_TRACER=y/" kernel/fairphone/sdm632/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
echo -e "\nCONFIG_DEBUG_FS=y" >> kernel/oneplus/sm8150/arch/arm64/configs/vendor/sm8150-perf_defconfig;
echo -e "\nCONFIG_DEBUG_FS=n" >> kernel/oneplus/sm8250/arch/arm64/configs/vendor/kona-perf_defconfig;

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l* || true; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
rm -v device/*/*/overlay/frameworks/base/packages/overlays/NoCutoutOverlay/res/values/config.xml || true;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
