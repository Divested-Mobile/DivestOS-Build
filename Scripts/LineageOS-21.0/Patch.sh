#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2015-2024 Divested Computing Group
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

#Last verified: 2024-05-20

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
if [ "$DOS_HOSTS_BLOCKING" = true ]; then wget --no-verbose "$DOS_HOSTS_BLOCKING_LIST" -N -O "$DOS_HOSTS_FILE"; fi;
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
cp -r "$DOS_PREBUILT_APPS/OpenEUICC" "$DOS_BUILD_BASE/packages/apps/"; #Add the OpenEUICC app
gpgVerifyDirectory "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/packages";
cp -r "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE/vendor/fdroid_prebuilt/"; #Add the prebuilt apps
cp -r "$DOS_PATCHES_COMMON/android_vendor_divested/." "$DOS_BUILD_BASE/vendor/divested/"; #Add our vendor files

if enterAndClear "art"; then
applyPatch "$DOS_PATCHES/android_art/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "bionic"; then
git revert --no-edit 7126ad39da09905c7096e85a30bf71ebf1016127; #Add ability to build scudo-free 32-bit libc variant.
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; #Use Scudo on 32-bit and hardened_malloc on 64-bit (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Runtime_Control-1.patch"; #Add a runtime option to disable hardened_malloc (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Runtime_Control-2.patch"; #Support assigning ID to path of current executable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Runtime_Control-3.patch"; #Support disabling hardened_malloc for specific program IDs (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Workaround-1.patch"; #Disable hardened_malloc for Pixel camera provider service (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Workaround-2.patch"; #Disable hardened_malloc for surfaceflinger (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-No_GWP_ASan.patch"; #Never enable GWP-ASan (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-1.patch"; #Add a real explicit_bzero implementation (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-2.patch"; #Replace brk and sbrk with stubs (GrapheneOS) #XXX: some vendor blobs use sbrk
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-3.patch"; #Use blocking getrandom and avoid urandom fallback (GrapheneOS) #XXX: some kernels do not have (working) getrandom
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-4.patch"; #Fix undefined out-of-bounds accesses in sched.h (GrapheneOS)
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
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Cache.patch"; #Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0003-Hosts_Wildcards.patch"; #Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_bionic/0004-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit aedf4a33fe4796e100ca1529fb2fcaa042f14f3b; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES/android_build/0003-Exec_Based_Spawning.patch"; #Add exec-based spawning support (GrapheneOS) #XXX: most devices override this
applyPatch "$DOS_PATCHES/android_build/0004-Selective_APEX.patch"; #Only enable APEX on 6th/7th gen Pixel devices (GrapheneOS)
sed -i '77i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES/android_build_soong/0002-hm_available.patch"; #(GrapheneOS)
fi;

if enterAndClear "external/chromium-webview"; then
git lfs pull; #Ensure the objects are available
fi;

if enterAndClear "external/conscrypt"; then
applyPatch "$DOS_PATCHES/android_external_conscrypt/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "external/hardened_malloc"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0001-Broken_Cameras-1.patch"; #Workarounds for Pixel 3 SoC era camera driver bugs (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0001-Broken_Cameras-2.patch"; #Expand workaround to all camera executables (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0002-Broken_Displays.patch"; #Add workaround for OnePlus 8 & 9 display driver crash (DivestOS)
sed -i 's/34359738368/2147483648/' Android.bp; #revert 48-bit address space requirement
sed -i -e '76,78d;' Android.bp; #fix compile under A13
fi;

if enterAndClear "frameworks/base"; then 
git revert --no-edit 32602dc51dc88664133eaa905bee62ed20c40c43; #Reverts "JobScheduler: Respect allow-in-power-save perm" in favor of below patch
git revert --no-edit f9b5586a3887e70aa5580f8073611826eed2b88f; #Reverts "Remove sensitive info from SUPL requests" in favor of below patch
git revert --no-edit 18f3b5a2615efe61636ff952b500b19d891bdc80; #Reverts "fixup! Allow signature spoofing for microG Companion/Services" in favor of below patch
git revert --no-edit 6b793fa98a40dd6c2d6eb02988161ed123439428; #Reverts "Allow signature spoofing for microG Companion/Services" in favor of below patch
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
applyPatch "$DOS_PATCHES/android_frameworks_base/0017-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-2.patch"; #Disable exec spawning when using debugging options (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-3.patch"; #Add parameter for avoiding full preload with exec (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-4.patch"; #Pass through fullPreload to libcore (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-5.patch"; #Disable OpenGL preloading for exec spawning (GrapheneOS) XXX: reverted upstream
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-6.patch"; #Disable resource preloading for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-7.patch"; #Disable class preloading for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-8.patch"; #Disable WebView reservation for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-9.patch"; #Disable JCA provider warm up for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-10.patch"; #Disable preloading classloaders for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-11.patch"; #Disable preloading HALs for exec spawning (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-12.patch"; #Pass through runtime flags for exec spawning and implement them in the child (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-13.patch"; #exec spawning: don't close the binder connection when the app crashes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-14.patch"; #exec spawning: support runtime resource overlays (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0018-Exec_Based_Spawning-15.patch"; #exec spawning: add workaround for late init of ART userfaultfd GC (GrapheneOS)
sed -i 's/sys.spawn.exec/persist.security.exec_spawn_new/' core/java/com/android/internal/os/ZygoteConnection.java;
applyPatch "$DOS_PATCHES/android_frameworks_base/0020-Location_Indicators.patch"; #SystemUI: Use new privacy indicators for location (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0022-Ignore_StatementService_ANR.patch"; #Don't report statementservice crashes (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/326692.patch"; #Skip screen on animation when wake and unlock via biometrics (jesec) #TODO: 20REBASE
#applyPatch "$DOS_PATCHES/android_frameworks_base/0023-Skip_Screen_Animation.patch"; #SystemUI: Skip screen-on animation in all scenarios (kdrag0n) #XXX: breaks notification backdrop #TODO: 20REBASE
applyPatch "$DOS_PATCHES/android_frameworks_base/0024-Burnin_Protection.patch"; #SystemUI: add burnIn protection (arter97)
applyPatch "$DOS_PATCHES/android_frameworks_base/0026-Crash_Details.patch"; #Add an option to show the details of an application error to the user (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0028-Remove_Legacy_Package_Query.patch"; #Don't leak device-wide package list to apps when work profile is present (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0029-Strict_Package_Checks-1.patch"; #Disable package parser cache (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0029-Strict_Package_Checks-2.patch"; #Perform additional boot-time checks on system package updates (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0030-agnss.goog_override.patch"; #Replace agnss.goog with the Broadcom PSDS server (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0031-appops_reset_fix-1.patch"; #Revert "Null safe package name in AppOps writeState" (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0031-appops_reset_fix-2.patch"; #appops: skip ops for invalid null package during state serialization (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0032-SUPL_Toggle.patch"; #Add a setting for forcibly disabling SUPL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0033-Ugly_Orbot_Workaround.patch"; #Always add Briar and Tor Browser to Orbot's lockdown allowlist (CalyxOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0034-Allow_Disabling_NTP.patch"; #Dont ping ntp server when nitz time update is toggled off (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0035-System_JobScheduler_Allowance.patch"; #DeviceIdleJobsController: don't ignore whitelisted system apps (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0036-Unprivileged_microG_Handling.patch"; #Unprivileged microG handling (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0037-filter-gms.patch"; #Filter select package queries for GMS (CalyxOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0038-no-camera-lpad.patch"; #Do not auto-grant Camera permission to the eUICC LPA UI app (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0039-package_hooks.patch"; #Add hooks for modifying PackageManagerService behavior (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0040-euicc-restrictions.patch"; #Integrate Google's EuiccSupportPixel package (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0041-tile_restrictions.patch"; #SystemUI: Require unlocking to use sensitive QS tiles (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0042-minimal_screenshot_exif.patch"; #Put bare minimum metadata in screenshots (CalyxOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0008-No_Crash_GSF.patch"; #Don't crash apps that depend on missing Gservices provider (GrapheneOS)
hardenLocationConf services/core/java/com/android/server/location/gnss/gps_debug.conf; #Harden the default GPS config
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!isBuildConsistent/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/MAX_PASSWORD_LENGTH = 16/MAX_PASSWORD_LENGTH = 64/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
#rm -rf packages/CompanionDeviceManager; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/ex"; then
applyPatch "$DOS_PATCHES/android_frameworks_ex/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "frameworks/libs/systemui"; then
applyPatch "$DOS_PATCHES/android_frameworks_libs_systemui/0001-Icon_Cache.patch"; #Invalidate icon cache between OS releases (GrapheneOS)
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors_Permission-1.patch"; #Require OTHER_SENSORS permission for sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors_Permission-2.patch"; #Protect step sensors with OTHER_SENSORS permission for targetSdk<29 apps (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors_Permission-3.patch"; #Exempt system processes from OTHER_SENSORS permission enforcement (GrapheneOS)
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

if enterAndClear "hardware/qcom-caf/msm8996/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8996.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
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
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8350.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "libcore"; then
applyPatch "$DOS_PATCHES/android_libcore/0001-Network_Permission.patch"; #Don't throw SecurityException when INTERNET permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0002-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0003-Exec_Based_Spawning-2.patch";
fi;

if enterAndClear "lineage-sdk"; then
applyPatch "$DOS_PATCHES/android_lineage-sdk/0001-Private_DNS-Migration.patch"; #Migrate Private DNS preset modes to hostname-mode based (heavily based off of a CalyxOS patch)
fi;

if enterAndClear "packages/apps/CellBroadcastReceiver"; then
applyPatch "$DOS_PATCHES/android_packages_apps_CellBroadcastReceiver/0001-presidential_alert_toggle.patch"; #Allow toggling presidential alerts (GrapheneOS)
fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0001-No_Google_Links.patch"; #Remove Privacy Policy and Terms of Service links (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0002-No_Google_Backup.patch"; #Backups are not sent to Google (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0003-Skip_Accounts.patch"; #Don't prompt to add account when creating a contact (CalyxOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0004-No_GMaps.patch"; #Use common intent for directions instead of Google Maps URL (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
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

if enterAndClear "packages/apps/Messaging"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Messaging/0001-null-fix.patch"; #Handle null case (GrapheneOS)
fi;

if enterAndClear "packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-prereq.patch"; #Revert 0dfbfff41cc28699c1e218e20b10d9d42688f950
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0006-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0007-WiFi_Timeout.patch"; #Timeout for Wi-Fi (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0008-ptrace_scope.patch"; #Add native debugging setting (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0010-exec_spawning_toggle.patch"; #Add exec spawning toggle (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0011-Random_MAC.patch"; #Add option to always randomize MAC (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0009-Install_Restrictions.patch"; #UserManager app installation restrictions (GrapheneOS) #TODO: 21REBASE
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0012-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0013-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0014-LTE_Only_Mode.patch"; #LTE Only Mode (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0015-SUPL_Toggle.patch"; #Add a toggle for forcibly disabling SUPL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0016-microG_Toggle.patch"; #Add a toggle for microG enablement (heavily based off of a GrapheneOS patch)
if [ "$DOS_DEBLOBBER_REMOVE_EUICC_FULL" = false ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0017-OpenEUICC_Toggle.patch"; fi; #Add a toggle for OpenEUICC enablement (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0018-disable_apps.patch"; #Add an ability to disable non-system apps from the "App info" screen (GrapheneOS)
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/Trebuchet"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/361248.patch"; #Launcher3: Allow toggling monochrome icons for all apps
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
if [ "$DOS_OTA_SERVER_EXTENDED" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0003-Server_Choices.patch"; fi; #Add server choices (DivestOS)
sed -i 's/PROP_BUILD_VERSION_INCREMENTAL);/PROP_BUILD_VERSION_INCREMENTAL).replaceAll("\\\\.", "");/' app/src/main/java/org/lineageos/updater/misc/Utils.java; #Remove periods from incremental version
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/modules/Connectivity"; then
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-1.patch"; #Enforce INTERNET permission per-uid instead of per-appId (GrapheneOS) #XXX: 21REBASE PROBABLY BROKEN
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-2.patch"; #Don't crash INTERNET-unaware apps that try to access NsdManager (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-3.patch"; #ConnectivityManager: pretend that network is down to INTERNET-unaware callers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_modules_Connectivity/0001-Network_Permission-4.patch"; #Fixup! don't crash INTERNET-unaware apps that try to access NsdManager (GrapheneOS)
fi;

if enterAndClear "packages/modules/DnsResolver"; then
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Cache.patch"; #DnsResolver: Sort and cache hosts file data for fast lookup (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0001-Hosts_Wildcards.patch"; #DnsResolver: Support wildcards in cached hosts file (tdm)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0002-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_modules_DnsResolver/0003-Reuse-align_ptr-in-hosts_cache.patch"; #Reuse align_ptr in hosts_cache (danielk43)
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
applyPatch "$DOS_PATCHES/android_packages_modules_Wifi/0001-Random_MAC.patch"; #Add support for always generating new random MAC (GrapheneOS)
fi;

if enterAndClear "packages/providers/DownloadProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "system/ca-certificates"; then
rm -rf files; #Remove old certs
cp -r "$DOS_PATCHES_COMMON/android_system_ca-certificates/files" .; #Copy the new ones into place
fi;

if enterAndClear "system/core"; then
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 75b64415b9dd9f0415eb9d5fd94caa5de482419f; #insanity
git revert --no-edit 3cf503f51ee4d1b2f51a517c644a85d02ac5cfcf; #unknown impact
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0002-ptrace_scope.patch"; #Add a property for controlling ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0003-HM-Increase_vm_mmc.patch"; #(GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #Label protected_{fifos,regular} as proc_security (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
awk -i inplace '!/domain=gmscore_app/' private/seapp_contexts prebuilts/api/*/private/seapp_contexts; #Disable unused gmscore_app domain (GrapheneOS)
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit 94e1a11f391d5d742e9e6aec4e333c14e7501e33; #Do not skip payload signature verification
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
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
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
if enterAndClear "device/google/gs101"; then
git revert --no-edit adfcf46ec8c099e77cf58ec87d02bafc78a0d01e; #potential breakage
if [ "$DOS_DEBLOBBER_REMOVE_CNE" = true ]; then sed -i '/google iwlan/,+8d' device.mk; fi; #fix stray
awk -i inplace '!/widevine.mk/' device.mk;
fi;

if enterAndClear "device/google/gs201"; then
if [ "$DOS_DEBLOBBER_REMOVE_CNE" = true ]; then sed -i '/google iwlan/,+8d' device.mk; fi; #fix stray
if [ "$DOS_DEBLOBBER_REMOVE_EUICC" = true ]; then sed -i '/eSIM MEP/,+4d' device.mk; fi; #fix stray
rm -rfv widevine;
awk -i inplace '!/widevine.mk/' device.mk;
fi;

if enterAndClear "device/google/gs-common"; then
rm -rfv widevine;
fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf*" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
#if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi; #TODO RETEST THIS
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableAPEX "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableEnforceRRO "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio;
removeBuildFingerprints;
hardenLocationSerials || true;
enableAutoVarInit || true;
changeDefaultDNS; #Change the default DNS servers
fixupCarrierConfigs || true; #Remove silly carrier restrictions
removeUntrustedCerts || true;
sed -i 's/SSLv23_NO_TLSv1_2/TLSv1_2/' device/*/*/gps*xml* device/*/*/location/gps*xml* device/*/*/gnss/*/config/gps*xml* || true; #Enforce TLSv1.2 for SUPL on Tensor devices (GrapheneOS)
cd "$DOS_BUILD_BASE";
#rm -rfv device/*/*/overlay/CarrierConfigResCommon device/*/*/rro_overlays/CarrierConfigOverlay device/*/*/overlay/packages/apps/CarrierConfig/res/xml/vendor.xml;

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
