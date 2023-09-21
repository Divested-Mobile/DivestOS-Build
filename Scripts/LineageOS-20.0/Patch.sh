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

#Last verified: 2022-10-15

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
if [ "$DOS_HOSTS_BLOCKING" = true ]; then $DOS_TOR_WRAPPER wget --no-verbose "$DOS_HOSTS_BLOCKING_LIST" -N -O "$DOS_HOSTS_FILE"; fi;
cd "$DOS_BUILD_BASE";
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#

#top dir
cp -r "$DOS_PREBUILT_APPS/Fennec_DOS-Shim" "$DOS_BUILD_BASE/packages/apps/"; #Add a shim to install Fennec DOS without actually including the large APK
cp -r "$DOS_PREBUILT_APPS/SupportDivestOS" "$DOS_BUILD_BASE/packages/apps/"; #Add the Support app
gpgVerifyDirectory "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/packages";
cp -r "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE/vendor/fdroid_prebuilt/"; #Add the prebuilt apps
cp -r "$DOS_PATCHES_COMMON/android_vendor_divested/." "$DOS_BUILD_BASE/vendor/divested/"; #Add our vendor files

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
if [ "$DOS_USE_KSM" = false ]; then applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-5.patch"; fi; #Stop implicitly marking mappings as mergeable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-6.patch"; #Replace VLA formatting with dprintf-like function (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-7.patch"; #Increase default pthread stack to 8MiB on 64-bit (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-8.patch"; #Make __stack_chk_guard read-only at runtime (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-9.patch"; #On 64-bit, zero the leading stack canary byte (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-10.patch"; #Switch pthread_atfork handler allocation to mmap (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-11.patch"; #Add memory protection for pthread_atfork handlers (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-12.patch"; #Add XOR mangling mitigation for thread-local dtors (GrapheneOS) #XXX: patches from here on are known to cause boot issues
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-13.patch"; #Use a better pthread_attr junk filling pattern (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-14.patch"; #Add guard page(s) between static_tls and stack (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-15.patch"; #Move pthread_internal_t behind guard page (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-16.patch"; #Add secondary stack randomization (GrapheneOS)
fi;
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Cache.patch"; #Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Wildcards.patch"; #Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0004-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit 9b41333a849d14683f9c4ac30fcfd48a27945018; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_build/0002-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_build/0003-Exec_Based_Spawning.patch"; fi; #Add exec-based spawning support (GrapheneOS) #XXX: most devices override this
applyPatch "$DOS_PATCHES/android_build/0004-Selective_APEX.patch"; #Only enable APEX on 6th/7th gen Pixel devices (GrapheneOS)
sed -i '75i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 23/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_util.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
#sed -i 's/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := true/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false/' core/product_config.mk; #broken by hardenDefconfig
sed -i 's/2023-08-05/2023-09-01/' core/version_defaults.mk; #Bump Security String #XXX
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
applyPatch "$DOS_PATCHES/android_external_hardened_malloc/0002-Broken_Displays.patch"; #Add workaround for OnePlus 8 & 9 display driver crash (DivestOS)
sed -i 's/34359738368/2147483648/' Android.bp; #revert 48-bit address space requirement
fi;
fi;

if enterAndClear "frameworks/base"; then
git revert --no-edit d36faad3267522c6d3ff91ba9dcca8f6274bccd1; #Reverts "JobScheduler: Respect allow-in-power-save perm" in favor of below patch
git revert --no-edit 90d6826548189ca850d91692e71fcc1be426f453; #Reverts "Remove sensitive info from SUPL requests" in favor of below patch
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after five failed attempts (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0005-User_Logout.patch"; #Enable secondary user logout support by default (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0005-User_Logout-a1.patch"; #Fix DevicePolicyManager#logoutUser() never succeeding (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-1.patch"; #Support new special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-2.patch"; #Make INTERNET into a special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-3.patch"; #Add special runtime permission for other sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-4.patch"; #Infrastructure for spoofing self permission checks (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-5.patch"; #App-side infrastructure for special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-6.patch"; #Improve compatibility of INTERNET special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-7.patch"; #Mark UserHandle#get{Uid, UserId} as module SystemApi (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-8.patch"; #Improve compatibility with revoked INTERNET in DownloadManager (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-9.patch"; #Ignore pid when spoofing permission checks (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions-10.patch"; #srt permissions: don't auto-grant denied ones when permissions are reset (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-System_Server_Extensions.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-WiFi_Timeout.patch"; #Timeout for Wi-Fi (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Bluetooth_Timeout-Fix.patch"; #bugfix: Bluetooth auto turn off ignored connected BLE devices (GrapheneOS)
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
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-14.patch";
sed -i 's/sys.spawn.exec/persist.security.exec_spawn_new/' core/java/com/android/internal/os/ZygoteConnection.java;
fi;
applyPatch "$DOS_PATCHES/android_frameworks_base/0020-Location_Indicators.patch"; #SystemUI: Use new privacy indicators for location (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0022-Ignore_StatementService_ANR.patch"; #Don't report statementservice crashes (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/326692.patch"; #Skip screen on animation when wake and unlock via biometrics (jesec) #TODO: 20REBASE
#applyPatch "$DOS_PATCHES/android_frameworks_base/0023-Skip_Screen_Animation.patch"; #SystemUI: Skip screen-on animation in all scenarios (kdrag0n) #XXX: breaks notification backdrop
applyPatch "$DOS_PATCHES/android_frameworks_base/0024-Burnin_Protection.patch"; #SystemUI: add burnIn protection (arter97)
applyPatch "$DOS_PATCHES/android_frameworks_base/0026-Crash_Details.patch"; #Add an option to show the details of an application error to the user (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0027-Installer_Glitch.patch"; #Make sure PackageInstaller UI returns a result (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0028-Remove_Legacy_Package_Query.patch"; #Don't leak device-wide package list to apps when work profile is present (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0029-Strict_Package_Checks-1.patch"; #Disable package parser cache (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0029-Strict_Package_Checks-2.patch"; #Perform additional boot-time checks on system package updates (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0029-Strict_Package_Checks-3.patch"; #Require fs-verity when installing system package updates (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0030-agnss.goog_override.patch"; #Replace agnss.goog with the Broadcom PSDS server (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0031-appops_reset_fix-1.patch"; #Revert "Null safe package name in AppOps writeState" (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0031-appops_reset_fix-2.patch"; #appops: skip ops for invalid null package during state serialization (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0032-SUPL_Toggle.patch"; #Add a setting for forcibly disabling SUPL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0033-Ugly_Orbot_Workaround.patch"; #Always add Briar and Tor Browser to Orbot's lockdown allowlist (CalyxOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0034-Allow_Disabling_NTP.patch"; #Dont ping ntp server when nitz time update is toggled off (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0035-System_JobScheduler_Allowance.patch"; #DeviceIdleJobsController: don't ignore whitelisted system apps (GrapheneOS)
if [ "$DOS_MICROG_SUPPORT" = true ]; then
applyPatch "$DOS_PATCHES/android_frameworks_base/0036-Unprivileged_microG_Handling.patch"; #Unprivileged microG handling (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0037-filter-gms.patch"; #Filter select package queries for GMS (CalyxOS)
fi;
applyPatch "$DOS_PATCHES/android_frameworks_base/0038-no-camera-lpad.patch"; #Do not auto-grant Camera permission to the eUICC LPA UI app (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0039-package_hooks.patch"; #Add hooks for modifying PackageManagerService behavior (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0040-euicc-restrictions.patch"; #Integrate Google's EuiccSupportPixel package (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0041-tile_restrictions.patch"; #SystemUI: Require unlocking to use sensitive QS tiles (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0008-No_Crash_GSF.patch"; #Don't crash apps that depend on missing Gservices provider (GrapheneOS)
hardenLocationConf services/core/java/com/android/server/location/gnss/gps_debug.conf; #Harden the default GPS config
sed -i 's/DEFAULT_USE_COMPACTION = false;/DEFAULT_USE_COMPACTION = true;/' services/core/java/com/android/server/am/CachedAppOptimizer.java; #Enable app compaction by default (GrapheneOS)
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/MAX_PASSWORD_LENGTH = 16/MAX_PASSWORD_LENGTH = 64/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
#rm -rf packages/CompanionDeviceManager; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/ex"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_ex/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
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
applyPatch "$DOS_PATCHES/android_libcore/0001-Network_Permission.patch"; #Don't throw SecurityException when INTERNET permission is revoked (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0002-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-2.patch";
fi;
fi;

if enterAndClear "lineage-sdk"; then
applyPatch "$DOS_PATCHES/android_lineage-sdk/0001-Private_DNS-Migration.patch"; #Migrate Private DNS preset modes to hostname-mode based (heavily based off of a CalyxOS patch)
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
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
#applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/0001-Not_Private_Banner.patch"; #Add a privacy warning banner to calls (CalyxOS) TODO: REBASE
sed -i 's/>true/>false/' java/com/android/incallui/res/values/lineage_config.xml; #XXX: temporary workaround for black screen on incoming calls https://gitlab.com/LineageOS/issues/android/-/issues/4632
fi;

if enterAndClear "packages/apps/ImsServiceEntitlement"; then
applyPatch "$DOS_PATCHES/android_packages_apps_ImsServiceEntitlement/0001-delay-fcm.patch"; #Delay FCM registration until it's actually required (CalyxOS)
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Nfc"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/OpenEUICC"; then
applyPatch "$DOS_PATCHES/android_packages_apps_OpenEUICC/0001-hacky-fix.patch"; #Hacky fix for misidentifying physical SIM (DivestOS)
fi;

if enterAndClear "packages/apps/Settings"; then
git revert --no-edit 41b4ed345a91da1dd46c00ee11a151c2b5ff4f43;
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
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0014-LTE_Only_Mode-1.patch"; #LTE Only Mode (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0014-LTE_Only_Mode-2.patch"; #Fix LTE Only mode on World Mode (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0015-SUPL_Toggle.patch"; #Add a toggle for forcibly disabling SUPL (GrapheneOS)
if [ "$DOS_MICROG_SUPPORT" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0016-microG_Toggle.patch"; fi; #Add a toggle for microG enablement (heavily based off of a GrapheneOS patch)
if [ "$DOS_DEBLOBBER_REMOVE_EUICC_FULL" = false ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0017-OpenEUICC_Toggle.patch"; fi; #Add a toggle for OpenEUICC enablement (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Settings/0001-disable_apps.patch"; #Add an ability to disable non-system apps from the "App info" screen (GrapheneOS)
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/ThemePicker"; then
git revert --no-edit fcf658d2005dc557a95d5a7fb89cb90d06b31d33; #grant permission by default, to prevent crashes, missing previews, and confusion
fi;

if enterAndClear "packages/apps/Trebuchet"; then
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
sed -i 's/PROP_BUILD_VERSION_INCREMENTAL);/PROP_BUILD_VERSION_INCREMENTAL).replaceAll("\\\\.", "");/' app/src/main/java/org/lineageos/updater/misc/Utils.java; #Remove periods from incremental version
#TODO: Remove changelog
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/modules/Connectivity"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-1.patch"; #Skip reportNetworkConnectivity() when permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-2.patch"; #Enforce INTERNET permission per-uid instead of per-appId (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-3.patch"; #Don't crash INTERNET-unaware apps that try to access NsdManager (GrapheneOS)
fi;

if enterAndClear "packages/modules/DnsResolver"; then
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Cache.patch"; #DnsResolver: Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Wildcards.patch"; #DnsResolver: Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0002-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0003-Reuse-align_ptr-in-hosts_cache.patch"; #Reuse align_ptr in hosts_cache (danielk43)
#applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0004-More-DoH.patch"; #Add more DoH endpoints (DivestOS)
fi;

if enterAndClear "packages/modules/NetworkStack"; then
applyPatch "$DOS_PATCHES/android_packages_modules_NetworkStack/0001-Random_MAC.patch"; #Avoid reusing DHCP state for full MAC randomization (GrapheneOS)
fi;

if enterAndClear "packages/modules/Permission"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permissions-1.patch"; #Add special handling for INTERNET/OTHER_SENSORS (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0004-Special_Permissions-2.patch"; #Fix usage UI summary for Network/Sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0005-Browser_No_Location.patch"; #Stop auto-granting location to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Permission/0006-Location_Indicators.patch"; #SystemUI: Use new privacy indicators for location (GrapheneOS)
fi;

if enterAndClear "packages/modules/Wifi"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/344228.patch"; #wifi: resurrect mWifiLinkLayerStatsSupported counter (sassmann)
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/0001-Random_MAC.patch"; #Add support for always generating new random MAC (GrapheneOS)
fi;

if enterAndClear "packages/providers/DownloadProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

#if enterAndClear "packages/providers/TelephonyProvider"; then
#cp $DOS_PATCHES_COMMON/android_packages_providers_TelephonyProvider/carrier_list.* assets/latest_carrier_id/;
#fi;

if enterAndClear "system/ca-certificates"; then
rm -rf files; #Remove old certs
cp -r "$DOS_PATCHES_COMMON/android_system_ca-certificates/files" .; #Copy the new ones into place
fi;

if enterAndClear "system/core"; then
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 7e2eeae6244ed16c2602480207659ebf0e21674a; #insanity
git revert --no-edit 942dd2ac9eed11d0ff31fb734de46c2da24b4b9b; #unknown impact
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0002-ptrace_scope.patch"; #Add a property for controlling ptrace_scope (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0003-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #Label protected_{fifos,regular} as proc_security (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
#awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
awk -i inplace '!/domain=gmscore_app/' private/seapp_contexts prebuilts/api/*/private/seapp_contexts; #Disable unused gmscore_app domain (GrapheneOS)
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit ac104e8990f3be3a3f111241e9328e7f98bfb912; #Do not skip payload signature verification
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
rm -rf overlay/rro_packages/NetworkStackOverlay; #Do not set device model as DHCP hostname
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/*.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/config_multiuserMaximumUsers/' overlay/common/frameworks/base/core/res/res/values/config.xml; #Conflict
sed -i '/config_locationExtraPackageNames/,+11d' overlay/common/frameworks/base/core/res/res/values/config.xml; #Conflict
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then sed -i '/TARGET_EXCLUDES_AUDIOFX/,+3d' config/common_full.mk; fi; #Remove AudioFX
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/*.mk; #Change buildtype
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
#cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
awk -i inplace '!/Eleven/' config/common_full.mk; #Remove Music Player
awk -i inplace '!/enforce-product-packages-exist-internal/' config/common.mk; #Ignore missing packages
cp -f "$DOS_PATCHES_COMMON/config_webview_packages.xml" overlay/common/frameworks/base/core/res/res/xml/config_webview_packages.xml; #Change allowed WebView providers
awk -i inplace '!/com.android.vending/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml; #Remove unwanted apps
awk -i inplace '!/com.google.android/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml;
fi;

if enter "vendor/divested"; then
awk -i inplace '!/_lookup/' overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove all lookup provider overrides
echo "PRODUCT_PACKAGES += eSpeakNG" >> packages.mk; #PicoTTS needs work to compile on 18.1, use eSpeak-NG instead
if [ "$DOS_DEBLOBBER_REMOVE_EUICC_FULL" = false ]; then echo "PRODUCT_PACKAGES += OpenEUICC" >> packages.mk; fi;
sed -i 's/OpenCamera/Aperture/' packages.mk; #Use the LineageOS camera app
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

if enterAndClear "device/fxtec/pro1"; then
echo "type qti_debugfs, fs_type, debugfs_type;" >> sepolicy/vendor/file.te; #fixup
fi;

if enterAndClear "device/google/gs101"; then
git revert --no-edit 371473c97a3769f9b0629b33ae7014e78e1e31bb; #potential breakage
if [ "$DOS_DEBLOBBER_REMOVE_CNE" = true ]; then sed -i '/google iwlan/,+8d' device.mk; fi; #fix stray
fi;

if enterAndClear "device/google/gs201"; then
if [ "$DOS_DEBLOBBER_REMOVE_CNE" = true ]; then sed -i '/google iwlan/,+8d' device.mk; fi; #fix stray
if [ "$DOS_DEBLOBBER_REMOVE_EUICC" = true ]; then sed -i '/eSIM MEP/,+4d' device.mk; fi; #fix stray
awk -i inplace '!/PRODUCT_PACKAGES/' widevine/device.mk;
fi;

if enterAndClear "device/google/redbull"; then
if [ "$DOS_DEFCONFIG_DISABLER" = true ]; then awk -i inplace '!/sctp/' BoardConfig-common.mk modules.load; fi; #fix compile after hardenDefconfig
fi;

if enterAndClear "device/google/muskie"; then
git revert --no-edit 19c8b61e1ae4b6598f5b6a4d328f4f6b7cd11244; #compile fix: out of space
fi;

if enterAndClear "device/google/taimen"; then
git revert --no-edit 0ba4518422b3c398590a3ffea77f3e65eaebe309; #compile fix: out of space
fi;

if enterAndClear "kernel/google/wahoo"; then
sed -i 's/asm(SET_PSTATE_UAO(1));/asm(SET_PSTATE_UAO(1)); return 0;/' arch/arm64/mm/fault.c; #fix build with CONFIG_ARM64_UAO
fi;

if enterAndClear "device/oneplus/msm8998-common"; then
#awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' BoardConfigCommon.mk; #disable releasetools to fix delta ota generation
sed -i '/PRODUCT_SYSTEM_VERITY_PARTITION/iPRODUCT_VENDOR_VERITY_PARTITION := /dev/block/bootdevice/by-name/vendor' common.mk; #Support verity on /vendor too
awk -i inplace '!/vendor_sensors_dbg_prop/' sepolicy/vendor/hal_camera_default.te; #fixup
echo "type qti_debugfs, fs_type, debugfs_type;" >> sepolicy/vendor/file.te; #fixup
fi;

if enterAndClear "device/xiaomi/mithorium-common"; then
awk -i inplace '!/vendor_sensors_dbg_prop/' sepolicy/vendor/vendor_init.te; #fixup
fi;

if enterAndClear "device/xiaomi/sdm845-common"; then
echo "persist.vendor.bt.aac_frm_ctl.enabled=true" >> vendor.prop; #Fixup stutters: https://review.lineageos.org/c/LineageOS/android_device_oneplus_sdm845-common/+/346925
fi;

if enterAndClear "hardware/oplus"; then
echo "allow update_engine_common vendor_custom_ab_block_device:blk_file rw_file_perms;" >> sepolicy/qti/vendor/update_engine_common.te; #fix firmware flash
fi;

if enterAndClear "kernel/fairphone/sdm632"; then
sed -i 's|/../../prebuilts/tools-lineage|/../../../prebuilts/tools-lineage|' lib/Makefile; #fixup typo
fi;

if enterAndClear "kernel/oneplus/sm7250"; then
git revert --no-edit 6eede8c64f268991abe669a6123e929e295fac29;
fi;

#if enterAndClear "kernel/oneplus/sm8250"; then
#git revert --no-edit 6eede8c64f268991abe669a6123e929e295fac29;
#fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf*" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
#if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi;
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableAPEX "{}"';
#if [ "$DOS_DEBLOBBER_REMOVE_EUICC_FULL" = false ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'includeOE "{}"'; fi;
if [ "$DOS_GRAPHENE_EXEC" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableEnforceRRO "{}"'; fi;
cd "$DOS_BUILD_BASE";
deblobAudio;
removeBuildFingerprints;
hardenLocationSerials || true;
enableAutoVarInit || true;
changeDefaultDNS; #Change the default DNS servers
fixupCarrierConfigs || true; #Remove silly carrier restrictions
removeUntrustedCerts || true;
cd "$DOS_BUILD_BASE";
#rm -rfv device/*/*/overlay/CarrierConfigResCommon device/*/*/rro_overlays/CarrierConfigOverlay device/*/*/overlay/packages/apps/CarrierConfig/res/xml/vendor.xml;

#Tweaks for <4GB RAM devices
enableLowRam "device/xiaomi/Mi8937" "Mi8917";
enableLowRam "device/xiaomi/Mi8937" "Mi8937";
#Tweaks for 3GB/4GB RAM devices
#enableLowRam "device/zuk/z2_plus" "z2_plus";
#Tweaks for 4GB RAM devices
#enableLowRam "device/essential/mata" "mata";
#enableLowRam "device/fairphone/FP3" "FP3";
#enableLowRam "device/google/bonito" "bonito";
#enableLowRam "device/google/bonito" "sargo";
#enableLowRam "device/google/crosshatch" "blueline";
#enableLowRam "device/google/crosshatch" "crosshatch";
#enableLowRam "device/google/muskie/walleye" "walleye";
#enableLowRam "device/google/taimen" "taimen";
#enableLowRam "device/samsung/starlte" "starlte";
#Tweaks for 4GB/6GB RAM devices
#enableLowRam "device/sony/akari" "akari";
#enableLowRam "device/sony/akatsuki" "akatsuki";
#enableLowRam "device/sony/xz2c" "xz2c";

#Fix broken options enabled by hardenDefconfig()
[[ -d kernel/fairphone/sdm632 ]] && sed -i "s/CONFIG_PREEMPT_TRACER=n/CONFIG_PREEMPT_TRACER=y/" kernel/fairphone/sdm632/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
[[ -d kernel/google/msm-4.9 ]] && sed -i "s/CONFIG_DEBUG_NOTIFIERS=y/# CONFIG_DEBUG_NOTIFIERS is not set/" kernel/google/msm-4.9/arch/arm64/configs/*_defconfig; #Likely breaks boot
[[ -d kernel/google/msm-4.14 ]] && sed -i "s/CONFIG_FORTIFY_SOURCE=y/# CONFIG_FORTIFY_SOURCE is not set/" kernel/google/msm-4.14/arch/arm64/configs/*_defconfig; #breaks compile
[[ -d kernel/google/msm-4.14 ]] && sed -i "s/CONFIG_MITIGATE_SPECTRE_BRANCH_HISTORY=y/# CONFIG_MITIGATE_SPECTRE_BRANCH_HISTORY is not set/" kernel/google/msm-4.14/arch/arm64/configs/*_defconfig; #impartial backport
[[ -d kernel/oneplus/sm8150 ]] && echo -e "\nCONFIG_DEBUG_FS=y" >> kernel/oneplus/sm8150/arch/arm64/configs/vendor/sm8150-perf_defconfig; #compile failure
[[ -d kernel/oneplus/sm7250 ]] && echo -e "\nCONFIG_DEBUG_FS=n" >> kernel/oneplus/sm7250/arch/arm64/configs/vendor/lito-perf_defconfig; #compile failure
[[ -d kernel/oneplus/sm8250 ]] && echo -e "\nCONFIG_DEBUG_FS=n" >> kernel/oneplus/sm8250/arch/arm64/configs/vendor/kona-perf_defconfig; #vintf failure
[[ -d kernel/samsung/exynos9810 ]] && sed -i "s/CONFIG_RANDOMIZE_BASE=y/# CONFIG_RANDOMIZE_BASE is not set/" kernel/samsung/exynos9810/arch/arm64/configs/*_defconfig; #Breaks on compile
[[ -d kernel/xiaomi/msm8937 ]] && sed -i "s/CONFIG_MITIGATE_SPECTRE_BRANCH_HISTORY=y/# CONFIG_MITIGATE_SPECTRE_BRANCH_HISTORY is not set/" kernel/xiaomi/msm8937/arch/arm64/configs/*_defconfig; #Breaks on compile

if [ "$DOS_DEBLOBBER_REMOVE_EUICC_FULL" = false ]; then sed -i '/<privapp-permissions/a\ \ \ \ \ \ \ \ <deny-permission name="android.permission.INTERNET" \/>' vendor/*/*/proprietary/*/etc/permissions/com.google.euiccpixel.xml; fi; #Remove network permission
sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l* || true; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
rm -v kernel/*/*/*/*/drivers/staging/greybus/tools/Android.mk || true;
rm -v device/*/*/overlay/frameworks/base/packages/overlays/NoCutoutOverlay/res/values/config.xml || true;
awk -i inplace '!/BOARD_AVB_ENABLE := false/' device/*/*/*.mk; #revert Lineage's signing hack

#Remove broken? charge control feature
awk -i inplace '!/hardware\/google\/pixel\/lineage_health\/device/' device/*/*/*.mk;
awk -i inplace '!/vendor.lineage.health-service.default/' device/*/*/*.mk;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
