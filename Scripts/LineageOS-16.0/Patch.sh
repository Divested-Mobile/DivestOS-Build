#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2015-2024 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
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
gpgVerifyDirectory "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/packages";
cp -r "$DOS_PREBUILT_APPS/android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE/vendor/fdroid_prebuilt/"; #Add the prebuilt apps
cp -r "$DOS_PATCHES_COMMON/android_vendor_divested/." "$DOS_BUILD_BASE/vendor/divested/"; #Add our vendor files

if enterAndClear "art"; then
applyPatch "$DOS_PATCHES/android_art/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "bionic"; then
applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; #(GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-1.patch"; #Add a real explicit_bzero implementation (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-2.patch"; #Replace brk and sbrk with stubs (GrapheneOS) #XXX: some vendor blobs use sbrk
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-3.patch"; #Use blocking getrandom and avoid urandom fallback (GrapheneOS) #XXX: some kernels do not have (working) getrandom
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-4.patch"; #Fix undefined out-of-bounds accesses in sched.h (GrapheneOS)
if [ "$DOS_USE_KSM" = false ]; then applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-5.patch"; fi; #Stop implicitly marking mappings as mergeable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-6.patch"; #Replace VLA formatting buffer with dprintf (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-7.patch"; #Increase default pthread stack to 8MiB on 64-bit (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-8.patch"; #Make __stack_chk_guard read-only at runtime (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-9.patch"; #On 64-bit, zero the leading stack canary byte (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-10.patch"; #Switch pthread_atfork handler allocation to mmap (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-11.patch"; #Add memory protection for pthread_atfork handlers (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-12.patch"; #Add memory protection for at_quick_exit (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-13.patch"; #Add XOR mangling mitigation for thread-local dtors (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-14.patch"; #Use a better pthread_attr junk filling pattern (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0002-Graphene_Bionic_Hardening-15.patch"; #Move pthread_internal_t out of the stack mapping (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0004-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "bootable/recovery"; then
git revert --no-edit 4d361ff13b5bd61d5a6a5e95063b24b8a37a24ab; #Always enforcing
git revert --no-edit 3f55a863ac34969f95bfb38641747d2fd9939630 865c6c770816f6e8099d6d93e04aeea35091a9d6; #Remove sideload cache, breaks with large files
git revert --no-edit 37d729bf; #Fix USB on most devices
git revert --no-edit fe2901b144c515c5a90b547198aed37c209b5a82; #Resurrect dm-verity
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
sed -i 's/!= 2048/< 2048/' tools/dumpkey/DumpPublicKey.java; #Allow 4096-bit keys
fi;

if enterAndClear "build/make"; then
git revert --no-edit 58544f3aa139b4603fa26c39e8d9259402d658b8; #Re-enable the downgrade check
git revert --no-edit 271f6ffa045064abcac066e97f2cb53ccb3e5126 61f7ee9386be426fd4eadc2c8759362edb5bef8; #Add back PicoTTS and language files
applyPatch "$DOS_PATCHES/android_build/0001-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
applyPatch "$DOS_PATCHES/android_build/0002-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_build/0001-verity-openssl3.patch"; #Fix VB 1.0 failure due to openssl output format change
sed -i '74i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 17/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_defaults.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
awk -i inplace '!/Email/' target/product/core.mk; #Remove Email
sed -i 's/2022-01-05/2024-08-05/' core/version_defaults.mk; #Bump Security String #P_asb_2024-08 #XXX
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
fi;

if enterAndClear "device/qcom/sepolicy-legacy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy-legacy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH (DivestOS)
echo "SELINUX_IGNORE_NEVERALLOWS := true" >> sepolicy.mk; #Ignore neverallow violations XXX: necessary for -user builds of legacy devices
fi;

if enterAndClear "external/aac"; then
#applyPatch "$DOS_PATCHES/android_external_aac/332775.patch"; #P_asb_2022-06 Reject invalid out of band config in transportDec_OutOfBandConfig() and skip re-allocation.
applyPatch "$DOS_PATCHES/android_external_aac/364605.patch"; #P_asb_2023-08 Increase patchParam array size by one and fix out-of-bounce write in resetLppTransposer().
fi;

if enterAndClear "external/chromium-webview"; then
git lfs pull; #Ensure the objects are available
fi;

if enterAndClear "external/conscrypt"; then
applyPatch "$DOS_PATCHES/android_external_conscrypt/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "external/dtc"; then
applyPatch "$DOS_PATCHES/android_external_dtc/342096.patch"; #P_asb_2022-10 libfdt: fdt_offset_ptr(): Fix comparison warnings
applyPatch "$DOS_PATCHES/android_external_dtc/344161.patch"; #P_asb_2022-11 Fix integer wrap sanitisation.
applyPatch "$DOS_PATCHES/android_external_dtc/345891.patch"; #P_asb_2022-12 libfdt: fdt_path_offset_namelen: Reject empty paths
fi;

if enterAndClear "external/expat"; then
applyPatch "$DOS_PATCHES/android_external_expat/338353.patch"; #P_asb_2022-09 Prevent integer overflow in copyString
applyPatch "$DOS_PATCHES/android_external_expat/338354.patch"; #P_asb_2022-09 Prevent XML_GetBuffer signed integer overflow
applyPatch "$DOS_PATCHES/android_external_expat/338355.patch"; #P_asb_2022-09 Prevent integer overflow in function doProlog
applyPatch "$DOS_PATCHES/android_external_expat/338356.patch"; #P_asb_2022-09 Prevent more integer overflows
applyPatch "$DOS_PATCHES/android_external_expat/349328.patch"; #P_asb_2023-02 [CVE-2022-43680] Fix overeager DTD destruction (fixes #649)
applyPatch "$DOS_PATCHES/android_external_expat/0001-lib-Reject-negative-len-for-XML_ParseBuffer.patch";
applyPatch "$DOS_PATCHES/android_external_expat/0002-lib-Detect-integer-overflow-in-dtdCopy.patch.patch";
applyPatch "$DOS_PATCHES/android_external_expat/0003-lib-Detect-integer-overflow-in-function-nextScaffold.patch";
applyPatch "$DOS_PATCHES/android_external_expat/0004-lib-Stop-leaking-opening-tag-bindings-after-closing-.patch";
fi;

if enterAndClear "external/freetype"; then
applyPatch "$DOS_PATCHES/android_external_freetype/361250.patch"; #P_asb_2023-07 Cherry-pick two upstream changes
applyPatch "$DOS_PATCHES/android_external_freetype/364606.patch"; #P_asb_2023-08 Cherrypick following three changes
fi;

if enterAndClear "external/hardened_malloc"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0001-Broken_Cameras-1.patch"; #Workarounds for Pixel 3 SoC era camera driver bugs (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0001-Broken_Cameras-2.patch"; #Expand workaround to all camera executables (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0002-Broken_Displays.patch"; #Add workaround for OnePlus 8 & 9 display driver crash (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0003-Broken_Audio.patch"; #Workaround for audio service sorting bug (GrapheneOS)
sed -i 's/34359738368/2147483648/' Android.bp; #revert 48-bit address space requirement
sed -i -e '76,78d;' Android.bp; #fix compile under A13
sed -i -e '22,24d;' androidtest/Android.bp; #fix compile under A12
awk -i inplace '!/vendor_ramdisk_available/' Android.bp; #fix compile under A11
rm -rfv androidtest; #fix compile under A11
sed -i -e '76,78d;' Android.bp; #fix compile under A10
awk -i inplace '!/ramdisk_available/' Android.bp; #fix compile under A10
git revert --no-edit 8974af86d12f7e29b54b5090133ab3d7eea0e519; #fix compile under A10
git revert --no-edit a28da3c65aed0528036da9ebd33e0c05b2c5884a; #fix compile under A9
mv include/h_malloc.h . ; #fix compile under A10
awk -i inplace '!/recovery_available/' Android.bp; #fix compile under A9
awk -i inplace '!/system_shared_libs/' Android.bp; #fix compile under A9
sed -i 's/c17/c11/' Android.bp; #fix compile under A9
fi;

if enterAndClear "external/libcups"; then
git fetch https://github.com/LineageOS/android_external_libcups refs/changes/32/374932/1 && git cherry-pick FETCH_HEAD; #P_asb_2023-11 Upgrade libcups to v2.3.1
git fetch https://github.com/LineageOS/android_external_libcups refs/changes/33/374933/1 && git cherry-pick FETCH_HEAD; #P_asb_2023-11 Upgrade libcups to v2.3.3
fi;

if enterAndClear "external/libvpx"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_libvpx/CVE-2023-5217.patch"; #VP8: disallow thread count changes
fi;

if enterAndClear "external/libxml2"; then
applyPatch "$DOS_PATCHES/android_external_libxml2/370701.patch"; #P_asb_2023-10 malloc-fail: Fix OOB read after xmlRegGetCounter
fi;

if enterAndClear "external/sonivox"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_sonivox/391896.patch"; #n-asb-2024-05 Fix buffer overrun in eas_wtengine
fi;

if enterAndClear "external/svox"; then
git revert --no-edit 1419d63b4889a26d22443fd8df1f9073bf229d3d; #Add back Makefiles
sed -i '12iLOCAL_SDK_VERSION := current' pico/Android.mk; #Fix build under Pie
sed -i 's/about to delete/unable to delete/' pico/src/com/svox/pico/LangPackUninstaller.java;
awk -i inplace '!/deletePackage/' pico/src/com/svox/pico/LangPackUninstaller.java;
fi;

if enterAndClear "external/zlib"; then
applyPatch "$DOS_PATCHES/android_external_zlib/351909.patch"; #P_asb_2023-03 Fix a bug when getting a gzip header extra field with inflate().
fi;

if enterAndClear "frameworks/av"; then
applyPatch "$DOS_PATCHES/android_frameworks_av/344167.patch"; #P_asb_2022-11 setSecurityLevel in clearkey
applyPatch "$DOS_PATCHES/android_frameworks_av/349329.patch"; #P_asb_2023-02 move MediaCodec metrics processing to looper thread
applyPatch "$DOS_PATCHES/android_frameworks_av/359729.patch"; #P_asb_2023-06 Fix NuMediaExtractor::readSampleData buffer Handling
applyPatch "$DOS_PATCHES/android_frameworks_av/366126.patch"; #P_asb_2023-09 Fix Segv on unknown address error flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/374924.patch"; #P_asb_2023-11 Fix for heap buffer overflow issue flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/377765.patch"; #P_asb_2023-12 httplive: fix use-after-free
applyPatch "$DOS_PATCHES/android_frameworks_av/379788.patch"; #P_asb_2024-01 Fix convertYUV420Planar16ToY410 overflow issue for unsupported cropwidth.
applyPatch "$DOS_PATCHES/android_frameworks_av/383562.patch"; #P_asb_2024-02 Update mtp packet buffer
applyPatch "$DOS_PATCHES/android_frameworks_av/385670.patch"; #P_asb_2024-03 Validate OMX Params for VPx encoders
applyPatch "$DOS_PATCHES/android_frameworks_av/385671.patch"; #P_asb_2024-03 Fix out of bounds read and write in onQueueFilled in outQueue
applyPatch "$DOS_PATCHES/android_frameworks_av/399771.patch"; #P_asb_2024-08 StagefrightRecoder: Disabling B-frame support
applyPatch "$DOS_PATCHES/android_frameworks_av/0001-HM-No_RLIMIT_AS.patch"; #(GrapheneOS)
fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/330961.patch"; #P_asb_2022-05 Keyguard - Treat messsages to lock with priority
applyPatch "$DOS_PATCHES/android_frameworks_base/330962.patch"; #P_asb_2022-05 Verify caller before auto granting slice permission
applyPatch "$DOS_PATCHES/android_frameworks_base/330963.patch"; #P_asb_2022-05 Always restart apps if base.apk gets updated.
applyPatch "$DOS_PATCHES/android_frameworks_base/332756.patch"; #P_asb_2022-06 Add finalizeWorkProfileProvisioning.
applyPatch "$DOS_PATCHES/android_frameworks_base/332757.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10; api doc update
applyPatch "$DOS_PATCHES/android_frameworks_base/332776.patch"; #P_asb_2022-06 Update GeofenceHardwareRequestParcelable to match parcel/unparcel format.
applyPatch "$DOS_PATCHES/android_frameworks_base/332777.patch"; #P_asb_2022-06 Add an OEM configurable limit for zen rules
applyPatch "$DOS_PATCHES/android_frameworks_base/332778.patch"; #P_asb_2022-06 Fix security hole in GateKeeperResponse
applyPatch "$DOS_PATCHES/android_frameworks_base/332779.patch"; #P_asb_2022-06 Prevent non-admin users from deleting system apps.
applyPatch "$DOS_PATCHES/android_frameworks_base/334256.patch"; #P_asb_2022-07 StorageManagerService: don't ignore failures to prepare user storage
applyPatch "$DOS_PATCHES/android_frameworks_base/334257.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery if preparing user storage fails
applyPatch "$DOS_PATCHES/android_frameworks_base/334258.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery for system user only
applyPatch "$DOS_PATCHES/android_frameworks_base/334259.patch"; #P_asb_2022-07 Ignore errors preparing user storage for existing users
applyPatch "$DOS_PATCHES/android_frameworks_base/334260.patch"; #P_asb_2022-07 Log to EventLog on prepareUserStorage failure
applyPatch "$DOS_PATCHES/android_frameworks_base/334262.patch"; #P_asb_2022-07 Crash invalid FGS notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/335117.patch"; #P_asb_2022-08 Only allow system and same app to apply relinquishTaskIdentity
applyPatch "$DOS_PATCHES/android_frameworks_base/335118.patch"; #P_asb_2022-08 Suppress notifications when device enter lockdown
applyPatch "$DOS_PATCHES/android_frameworks_base/335119.patch"; #P_asb_2022-08 Remove package title from notification access confirmation intent
applyPatch "$DOS_PATCHES/android_frameworks_base/335120.patch"; #P_asb_2022-08 Stop using invalid URL to prevent unexpected crash
applyPatch "$DOS_PATCHES/android_frameworks_base/335121.patch"; #P_asb_2022-08 Only allow the system server to connect to sync adapters
applyPatch "$DOS_PATCHES/android_frameworks_base/338346.patch"; #P_asb_2022-09 Fix duplicate permission privilege escalation
applyPatch "$DOS_PATCHES/android_frameworks_base/338347.patch"; #P_asb_2022-09 Parcel: recycle recycles
applyPatch "$DOS_PATCHES/android_frameworks_base/338348.patch"; #P_asb_2022-09 IMMS: Make IMMS PendingIntents immutable
applyPatch "$DOS_PATCHES/android_frameworks_base/338349.patch"; #P_asb_2022-09 Remove package name from SafetyNet logs
applyPatch "$DOS_PATCHES/android_frameworks_base/342100.patch"; #P_asb_2022-10 Limit the number of concurrently snoozed notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/344168.patch"; #P_asb_2022-11 Move accountname and typeName length check from Account.java to AccountManagerService.
applyPatch "$DOS_PATCHES/android_frameworks_base/344169.patch"; #P_asb_2022-11 switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_frameworks_base/344170.patch"; #P_asb_2022-11 Do not send new Intent to non-exported activity when navigateUpTo
applyPatch "$DOS_PATCHES/android_frameworks_base/344171.patch"; #P_asb_2022-11 Do not send AccessibilityEvent if notification is for different user.
applyPatch "$DOS_PATCHES/android_frameworks_base/344172.patch"; #P_asb_2022-11 Trim any long string inputs that come in to AutomaticZenRule
applyPatch "$DOS_PATCHES/android_frameworks_base/344173.patch"; #P_asb_2022-11 Check permission for VoiceInteraction
applyPatch "$DOS_PATCHES/android_frameworks_base/344174.patch"; #P_asb_2022-11 Do not dismiss keyguard after SIM PUK unlock
applyPatch "$DOS_PATCHES/android_frameworks_base/345892.patch"; #P_asb_2022-12 Revert "Prevent non-admin users from deleting system apps."
applyPatch "$DOS_PATCHES/android_frameworks_base/345893.patch"; #P_asb_2022-12 Limit the size of NotificationChannel and NotificationChannelGroup
applyPatch "$DOS_PATCHES/android_frameworks_base/345894.patch"; #P_asb_2022-12 Prevent non-admin users from deleting system apps.
applyPatch "$DOS_PATCHES/android_frameworks_base/345895.patch"; #P_asb_2022-12 Validate package name passed to setApplicationRestrictions.
applyPatch "$DOS_PATCHES/android_frameworks_base/345896.patch"; #P_asb_2022-12 Include all enabled services when FEEDBACK_ALL_MASK.
applyPatch "$DOS_PATCHES/android_frameworks_base/345897.patch"; #P_asb_2022-12 [pm] forbid deletion of protected packages
applyPatch "$DOS_PATCHES/android_frameworks_base/345898.patch"; #P_asb_2022-12 Fix NPE
applyPatch "$DOS_PATCHES/android_frameworks_base/345899.patch"; #P_asb_2022-12 Fix a security issue in app widget service.
applyPatch "$DOS_PATCHES/android_frameworks_base/345900.patch"; #P_asb_2022-12 Ignore malformed shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/345901.patch"; #P_asb_2022-12 Fix permanent denial of service via setComponentEnabledSetting
applyPatch "$DOS_PATCHES/android_frameworks_base/345902.patch"; #P_asb_2022-12 Add safety checks on KEY_INTENT mismatch.
applyPatch "$DOS_PATCHES/android_frameworks_base/347044.patch"; #P_asb_2023-01 Limit lengths of fields in Condition to a max length.
applyPatch "$DOS_PATCHES/android_frameworks_base/347045.patch"; #P_asb_2023-01 Disable all A11yServices from an uninstalled package.
applyPatch "$DOS_PATCHES/android_frameworks_base/347046.patch"; #P_asb_2023-01 Fix conditionId string trimming in AutomaticZenRule
applyPatch "$DOS_PATCHES/android_frameworks_base/347047.patch"; #P_asb_2023-01 [SettingsProvider] mem limit should be checked before settings are updated
applyPatch "$DOS_PATCHES/android_frameworks_base/347048.patch"; #P_asb_2023-01 Revert "Revert "Validate permission tree size..."
applyPatch "$DOS_PATCHES/android_frameworks_base/347049.patch"; #P_asb_2023-01 [SettingsProvider] key size limit for mutating settings
applyPatch "$DOS_PATCHES/android_frameworks_base/347050.patch"; #P_asb_2023-01 Revoke SYSTEM_ALERT_WINDOW on upgrade past api 23
applyPatch "$DOS_PATCHES/android_frameworks_base/347051.patch"; #P_asb_2023-01 Add protections agains use-after-free issues if cancel() or queue() is called after a device connection has been closed.
applyPatch "$DOS_PATCHES/android_frameworks_base/349330.patch"; #P_asb_2023-02 Correct the behavior of ACTION_PACKAGE_DATA_CLEARED
applyPatch "$DOS_PATCHES/android_frameworks_base/349331.patch"; #P_asb_2023-02 Convert argument to intent in ChooseTypeAndAccountActivity
applyPatch "$DOS_PATCHES/android_frameworks_base/351910.patch"; #P_asb_2023-03 Move service initialization
applyPatch "$DOS_PATCHES/android_frameworks_base/351911.patch"; #P_asb_2023-03 Enable user graularity for lockdown mode
applyPatch "$DOS_PATCHES/android_frameworks_base/351912.patch"; #P_asb_2023-03 Revoke dev perm if app is upgrading to post 23 and perm has pre23 flag
applyPatch "$DOS_PATCHES/android_frameworks_base/351913.patch"; #P_asb_2023-03 Reconcile WorkSource parcel and unparcel code.
applyPatch "$DOS_PATCHES/android_frameworks_base/354242.patch"; #P_asb_2023-04 Context#startInstrumentation could be started from SHELL only now.
applyPatch "$DOS_PATCHES/android_frameworks_base/354243.patch"; #P_asb_2023-04 Checking if package belongs to UID before registering broadcast receiver
applyPatch "$DOS_PATCHES/android_frameworks_base/354244.patch"; #P_asb_2023-04 Fix checkKeyIntentParceledCorrectly's bypass
applyPatch "$DOS_PATCHES/android_frameworks_base/354245.patch"; #P_asb_2023-04 Encode Intent scheme when serializing to URI string RESTRICT AUTOMERGE
applyPatch "$DOS_PATCHES/android_frameworks_base/356154.patch"; #P_asb_2023-05 Checks if AccessibilityServiceInfo is within parcelable size.
applyPatch "$DOS_PATCHES/android_frameworks_base/356155.patch"; #P_asb_2023-05 Uri: check authority and scheme as part of determining URI path
applyPatch "$DOS_PATCHES/android_frameworks_base/356156.patch"; #P_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_frameworks_base/359730.patch"; #P_asb_2023-06 Check key intent for selectors and prohibited flags
applyPatch "$DOS_PATCHES/android_frameworks_base/359731.patch"; #P_asb_2023-06 Handle invalid data during job loading.
applyPatch "$DOS_PATCHES/android_frameworks_base/359732.patch"; #P_asb_2023-06 Allow filtering of services
applyPatch "$DOS_PATCHES/android_frameworks_base/359733.patch"; #P_asb_2023-06 Prevent RemoteViews crashing SystemUi
applyPatch "$DOS_PATCHES/android_frameworks_base/361254.patch"; #P_asb_2023-07 Sanitize VPN label to prevent HTML injection
applyPatch "$DOS_PATCHES/android_frameworks_base/361255.patch"; #P_asb_2023-07 Limit the number of supported v1 and v2 signers
applyPatch "$DOS_PATCHES/android_frameworks_base/361256.patch"; #P_asb_2023-07 Import translations. DO NOT MERGE ANYWHERE
applyPatch "$DOS_PATCHES/android_frameworks_base/361257.patch"; #P_asb_2023-07 Dismiss keyguard when simpin auth'd and...
applyPatch "$DOS_PATCHES/android_frameworks_base/361258.patch"; #P_asb_2023-07 Truncate ShortcutInfo Id
applyPatch "$DOS_PATCHES/android_frameworks_base/361259.patch"; #P_asb_2023-07 Visit URIs in landscape/portrait custom remote views.
applyPatch "$DOS_PATCHES/android_frameworks_base/364607.patch"; #P_asb_2023-08 ActivityManager#killBackgroundProcesses can kill caller's own app only
applyPatch "$DOS_PATCHES/android_frameworks_base/364608.patch"; #P_asb_2023-08 Verify URI permissions for notification shortcutIcon.
applyPatch "$DOS_PATCHES/android_frameworks_base/364609.patch"; #P_asb_2023-08 On device lockdown, always show the keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/364610.patch"; #P_asb_2023-08 Ensure policy has no absurdly long strings
applyPatch "$DOS_PATCHES/android_frameworks_base/364611.patch"; #P_asb_2023-08 Implement visitUris for RemoteViews ViewGroupActionAdd.
applyPatch "$DOS_PATCHES/android_frameworks_base/364612.patch"; #P_asb_2023-08 Check URIs in notification public version.
applyPatch "$DOS_PATCHES/android_frameworks_base/364613.patch"; #P_asb_2023-08 Verify URI permissions in MediaMetadata
applyPatch "$DOS_PATCHES/android_frameworks_base/364614.patch"; #P_asb_2023-08 Use Settings.System.getIntForUser instead of getInt to make sure user specific settings are used
applyPatch "$DOS_PATCHES/android_frameworks_base/364615.patch"; #P_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_frameworks_base/366127.patch"; #P_asb_2023-09 Forbid granting access to NLSes with too-long component names
applyPatch "$DOS_PATCHES/android_frameworks_base/366128.patch"; #P_asb_2023-09 Update AccountManagerService checkKeyIntentParceledCorrectly.
applyPatch "$DOS_PATCHES/android_frameworks_base/370693.patch"; #P_asb_2023-10 RingtoneManager: verify default ringtone is audio
applyPatch "$DOS_PATCHES/android_frameworks_base/370694.patch"; #P_asb_2023-10 Do not share key mappings with JNI object
applyPatch "$DOS_PATCHES/android_frameworks_base/370695.patch"; #P_asb_2023-10 Verify URI Permissions in Autofill RemoteViews
applyPatch "$DOS_PATCHES/android_frameworks_base/370696.patch"; #P_asb_2023-10 Fix KCM key mapping cloning
applyPatch "$DOS_PATCHES/android_frameworks_base/370697.patch"; #P_asb_2023-10 Disallow loading icon from content URI to PipMenu
applyPatch "$DOS_PATCHES/android_frameworks_base/370698.patch"; #P_asb_2023-10 Fixing DatabaseUtils to detect malformed UTF-16 strings
applyPatch "$DOS_PATCHES/android_frameworks_base/370699.patch"; #P_asb_2023-10 Revert "Dismiss keyguard when simpin auth'd and..."
applyPatch "$DOS_PATCHES/android_frameworks_base/374921.patch"; #P_asb_2023-11 Fix BAL via notification.publicVersion
applyPatch "$DOS_PATCHES/android_frameworks_base/374922.patch"; #P_asb_2023-11 Use type safe API of readParcelableArray
applyPatch "$DOS_PATCHES/android_frameworks_base/374923.patch"; #P_asb_2023-11 [SettingsProvider] verify ringtone URI before setting
applyPatch "$DOS_PATCHES/android_frameworks_base/377766.patch"; #P_asb_2023-12 Visit Uris added by WearableExtender
applyPatch "$DOS_PATCHES/android_frameworks_base/377767.patch"; #P_asb_2023-12 Drop invalid data.
applyPatch "$DOS_PATCHES/android_frameworks_base/377768.patch"; #P_asb_2023-12 Require permission to unlock keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/377769.patch"; #P_asb_2023-12 Use readUniqueFileDescriptor in incidentd service
applyPatch "$DOS_PATCHES/android_frameworks_base/377770.patch"; #P_asb_2023-12 Validate userId when publishing shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/377771.patch"; #P_asb_2023-12 Revert "On device lockdown, always show the keyguard"
applyPatch "$DOS_PATCHES/android_frameworks_base/377772.patch"; #P_asb_2023-12 Adding in verification of calling UID in onShellCommand
applyPatch "$DOS_PATCHES/android_frameworks_base/377773.patch"; #P_asb_2023-12 Updated: always show the keyguard on device lockdown
applyPatch "$DOS_PATCHES/android_frameworks_base/379789.patch"; #P_asb_2024-01 Dismiss keyguard when simpin auth'd and...
applyPatch "$DOS_PATCHES/android_frameworks_base/379790.patch"; #P_asb_2024-01 Ensure finish lockscreen when usersetup incomplete
applyPatch "$DOS_PATCHES/android_frameworks_base/379791.patch"; #P_asb_2024-01 Truncate user data to a limit of 500 characters
applyPatch "$DOS_PATCHES/android_frameworks_base/379792.patch"; #P_asb_2024-01 Validate component name length before requesting notification access.
applyPatch "$DOS_PATCHES/android_frameworks_base/379793.patch"; #P_asb_2024-01 Log to detect usage of whitelistToken when sending non-PI target
applyPatch "$DOS_PATCHES/android_frameworks_base/379794.patch"; #P_asb_2024-01 Fix vulnerability that allowed attackers to start arbitary activities
applyPatch "$DOS_PATCHES/android_frameworks_base/379980.patch"; #P_asb_2024-01 Fix ActivityManager#killBackgroundProcesses permissions
applyPatch "$DOS_PATCHES/android_frameworks_base/383563.patch"; #P_asb_2024-02 Unbind TileService onNullBinding
applyPatch "$DOS_PATCHES/android_frameworks_base/385672.patch"; #P_asb_2024-03 Resolve custom printer icon boundary exploit.
applyPatch "$DOS_PATCHES/android_frameworks_base/385673.patch"; #P_asb_2024-03 Disallow system apps to be installed/updated as instant.
applyPatch "$DOS_PATCHES/android_frameworks_base/385674.patch"; #P_asb_2024-03 Close AccountManagerService.session after timeout.
applyPatch "$DOS_PATCHES/android_frameworks_base/389269.patch"; #P_asb_2024-04 isUserInLockDown can be true when there are other strong auth requirements
applyPatch "$DOS_PATCHES/android_frameworks_base/389270.patch"; #P_asb_2024-04 Fix security vulnerability that creates user with no restrictions when accountOptions are too long.
applyPatch "$DOS_PATCHES/android_frameworks_base/394877.patch"; #P_asb_2024-06 Verify URI permission for channel sound update from NotificationListenerService
applyPatch "$DOS_PATCHES/android_frameworks_base/399075-backport.patch"; #Q_asb_2024-06 Added throttle when reporting shortcut usage
applyPatch "$DOS_PATCHES/android_frameworks_base/399076.patch"; #Q_asb_2024-06 Prevend user spoofing in isRequestPinItemSupported
applyPatch "$DOS_PATCHES/android_frameworks_base/394878.patch"; #P_asb_2024-06 Add more checkKeyIntent checks to AccountManagerService.
applyPatch "$DOS_PATCHES/android_frameworks_base/394879.patch"; #P_asb_2024-06 Adds additional sanitization for Zygote command arguments.
applyPatch "$DOS_PATCHES/android_frameworks_base/394880.patch"; #P_asb_2024-06 Check hidden API exemptions
applyPatch "$DOS_PATCHES/android_frameworks_base/394881.patch"; #P_asb_2024-06 AccessibilityManagerService: remove uninstalled services from enabled list after service update.
applyPatch "$DOS_PATCHES/android_frameworks_base/394882.patch"; #P_asb_2024-06 Check permissions for CDM shell commands
applyPatch "$DOS_PATCHES/android_frameworks_base/397594.patch"; #P_asb_2024-07 Verify UID of incoming Zygote connections.
applyPatch "$DOS_PATCHES/android_frameworks_base/397595.patch"; #P_asb_2024-07 Fix security vulnerability of non-dynamic permission removal
applyPatch "$DOS_PATCHES/android_frameworks_base/399769.patch"; #P_asb_2024-08 Restrict USB poups while setup is in progress
applyPatch "$DOS_PATCHES/android_frameworks_base/399770.patch"; #P_asb_2024-08 Hide SAW subwindows
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0009-SystemUI_No_Permission_Review.patch"; #Allow SystemUI to directly manage Bluetooth/WiFi (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-2.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-3.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-4.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-5.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-6.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-7.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-8.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-9.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-10.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-11.patch";
sed -i 's/sys.spawn.exec/persist.security.exec_spawn_new/' core/java/com/android/internal/os/ZygoteConnection.java;
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after five failed attempts (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0005-User_Logout.patch"; #Allow user logout (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0012-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Special_Permissions.patch"; #Support new special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-1.patch"; #Make INTERNET into a special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Network_Permission-2.patch"; #Add a NETWORK permission group for INTERNET (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Sensors_Permission.patch"; #Add special runtime permission for other sensors (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0016-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/0021-Unprivileged_microG_Handling.patch"; #Unprivileged microG handling (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0008-No_Crash_GSF.patch"; #Don't crash apps that depend on missing Gservices provider (GrapheneOS)
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/am/ActivityManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/return 16;/return 64;/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
hardenLocationFWB "$DOS_BUILD_BASE"; #Harden the default GPS config
sed -i '301i\        if(packageList != null && packageList.length() > 0) { packageList += ","; } packageList += "net.sourceforge.opencamera";' core/java/android/hardware/Camera.java; #Add Open Camera to aux camera allowlist
#rm -rf packages/CompanionDeviceManager; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/minikin"; then
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345903.patch"; #P_asb_2022-12 Fix OOB read for registerLocaleList
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345904.patch"; #P_asb_2022-12 Fix OOB crash for registerLocaleList
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/356151.patch"; #P_asb_2023-05 Check for malformed Sensor Flattenable
applyPatch "$DOS_PATCHES/android_frameworks_native/356152.patch"; #P_asb_2023-05 Remove some new memory leaks from SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/356153.patch"; #P_asb_2023-05 Add removeInstanceForPackageMethod to SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/366129.patch"; #P_asb_2023-09 Allow sensors list to be empty
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed (DivestOS)
fi;
fi;

if enterAndClear "frameworks/opt/net/wifi"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "frameworks/opt/telephony"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_telephony/334263.patch"; #P_asb_2022-07 Enforce privileged phone state for getSubscriptionProperty(GROUP_UUID)
fi;

if enterAndClear "hardware/nxp/nfc"; then
applyPatch "$DOS_PATCHES/android_hardware_nxp_nfc/344180.patch"; #P_asb_2022-11 OOBW in phNxpNciHal_write_unlocked()
fi;

if enterAndClear "hardware/qcom/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory="msm8084"; #(Qualcomm)
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch" --directory="msm8226";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch" --directory="msm8960";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch" --directory="msm8974";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch" --directory="msm8994";
#TODO: missing msm8909, msm8996, msm8998, sdm845, sdm8150
fi;

if enterAndClear "hardware/qcom/display-caf/apq8084"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-apq8084.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8916"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8952"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8952.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8960"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8974"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8994"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8996"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8996.patch";
fi;

if enterAndClear "hardware/qcom/display-caf/msm8998"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8998.patch";
fi;

if enterAndClear "libcore"; then
applyPatch "$DOS_PATCHES/android_libcore/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0002-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "lineage-sdk"; then
awk -i inplace '!/LineageWeatherManagerService/' lineage/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Bluetooth"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332758.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setScanMode by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332759.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setDiscoverableTimeout by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/345907.patch"; #P_asb_2022-12 Fix URI check in BluetoothOppUtility.java
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/349332.patch"; #P_asb_2023-02 Fix OPP comparison
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/377774.patch"; #P_asb_2023-12 Fix UAF in ~CallbackEnv
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/Car/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Car_Settings/358565-backport.patch"; #R_asb_2023-06 Convert argument to Intent in car settings AddAccountActivity.
fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/332760.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0001-No_Google_Links.patch"; #Remove Privacy Policy and Terms of Service links (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0003-Skip_Accounts.patch"; #Don't prompt to add account when creating a contact (CalyxOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0004-No_GMaps.patch"; #Use common intent for directions instead of Google Maps URL (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0005-vCard-Four.patch"; #Add basic support for vCard 4.0 (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/332761.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/0001-Not_Private_Banner.patch"; #Add a privacy warning banner to calls (CalyxOS)
fi;

if enterAndClear "packages/apps/EmergencyInfo"; then
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/342101.patch"; #P_asb_2022-06 Prevent exfiltration of system files via user image settings.
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/345908.patch"; #P_asb_2022-12 Revert "Prevent exfiltration of system files via user image settings."
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/345909.patch"; #P_asb_2022-12 Prevent exfiltration of system files via avatar picker.
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/349333.patch"; #P_asb_2023-02 Removes unnecessary permission from the EmergencyInfo app.
fi;

if enterAndClear "packages/apps/KeyChain"; then
applyPatch "$DOS_PATCHES/android_packages_apps_KeyChain/334264.patch"; #P_asb_2022-07 Encode authority part of uri before showing in UI
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Messaging"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Messaging/0001-null-fix.patch"; #Handle null case (GrapheneOS)
#applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Messaging/0002-missing-channels.patch"; #Add notification channels where missing (LineageOS)
fi;

if enterAndClear "packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/332762.patch"; #P_asb_2022-06 OOB read in phNciNfc_RecvMfResp()
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/347043.patch"; #P_asb_2023-01 OOBW in Mfc_Transceive()
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/PackageInstaller"; then
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/344181.patch"; #P_asb_2022-11 Hide overlays on ReviewPermissionsAtivity
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/0001-Network_Permission-1.patch"; #Always treat INTERNET as a runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/0001-Network_Permission-2.patch"; #Add NETWORK permission group (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/0001-Sensors_Permission-1.patch"; #Add OTHER_SENSORS permission group (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/0001-Sensors_Permission-2.patch"; #Always treat OTHER_SENSORS as a runtime permission (GrapheneOS)
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/330960.patch"; #P_asb_2022-05 Hide private DNS settings UI in Guest mode
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/332763.patch"; #P_asb_2022-06 Prevent exfiltration of system files via user image settings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334265.patch"; #P_asb_2022-07 Fix LaunchAnyWhere in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335111.patch"; #P_asb_2022-08 Verify ringtone from ringtone picker is audio
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335112.patch"; #P_asb_2022-08 Make bluetooth not discoverable via SliceDeepLinkTrampoline
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335113.patch"; #P_asb_2022-08 Fix: policy enforcement for location wifi scanning
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335114.patch"; #P_asb_2022-08 Fix Settings crash when setting a null ringtone
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335115.patch"; #P_asb_2022-08 Fix can't change notification sound for work profile.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335116.patch"; #P_asb_2022-08 Extract app label from component name in notification access confirmation UI
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345910.patch"; #P_asb_2022-12 Revert "Prevent exfiltration of system files via user image settings."
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345911.patch"; #P_asb_2022-12 Prevent exfiltration of system files via avatar picker.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345912.patch"; #P_asb_2022-12 Add FLAG_SECURE for ChooseLockPassword and Pattern
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/351914.patch"; #P_asb_2023-03 FRP bypass defense in the settings app
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/351915.patch"; #P_asb_2023-03 Add DISALLOW_APPS_CONTROL check into uninstall app for all users
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/359734.patch"; #P_asb_2023-06 Convert argument to intent in AddAccountSettings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/366136.patch"; #P_asb_2023-09 Prevent non-system IME from becoming device admin
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/370700.patch"; #P_asb_2023-10 Restrict ApnEditor settings
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/316891059-16.patch"; #x-asb_2024-05 Replace getCallingActivity() with getLaunchedFromPackage()
git revert --no-edit c240992b4c86c7f226290807a2f41f2619e7e5e8; #Don't hide OEM unlock
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch) #TODO: Needs work
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0006-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (CalyxOS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0008-ptrace_scope.patch"; #Add native debugging setting (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0009-exec_spawning_toggle.patch"; #Add exec spawning toggle (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0012-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (heavily based off of a GrapheneOS patch)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0014-microG_Toggle.patch"; #Add a toggle for microG enablement (heavily based off of a GrapheneOS patch)
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 64;/' src/com/android/settings/password/ChooseLockPassword.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/Traceur"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/378475.patch"; #P_asb_2023-06 Update Traceur to check admin user status
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/378476.patch"; #P_asb_2023-06 Add DISALLOW_DEBUGGING_FEATURES check
fi;

if enterAndClear "packages/apps/Trebuchet"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/366137.patch"; #P_asb_2023-09 Fix permission issue in legacy shortcut
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/377775.patch"; #P_asb_2023-12 Fix permission bypass in legacy shortcut
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/TvSettings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_TvSettings/359735.patch"; #P_asb_2023-06 Convert argument to intent in addAccount TvSettings.
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
sed -i 's/PROP_BUILD_VERSION_INCREMENTAL);/PROP_BUILD_VERSION_INCREMENTAL).replaceAll("\\\\.", "");/' src/org/lineageos/updater/misc/Utils.java; #Remove periods from incremental version
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/providers/ContactsProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_ContactsProvider/335110.patch"; #P_asb_2022-08 enforce stricter CallLogProvider query
fi;

if enterAndClear "packages/providers/DownloadProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/383567.patch"; #P_asb_2024-02 Consolidate queryChildDocumentsXxx() implementations
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "packages/providers/TelephonyProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/344182.patch"; #P_asb_2022-11 Check dir path before updating permissions.
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/364616.patch"; #P_asb_2023-08 Update file permissions using canonical path
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/374920.patch"; #P_asb_2023-11 Block access to sms/mms db from work profile.
fi;

if enterAndClear "packages/services/BuiltInPrintService"; then
applyPatch "$DOS_PATCHES/android_packages_services_BuiltInPrintService/374919.patch"; #P_asb_2023-11 Adjust APIs for CUPS 2.3.3
fi;

if enterAndClear "packages/services/Telecomm"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/330959.patch"; #P_asb_2022-05 Handle null bindings returned from ConnectionService.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/332764.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/344183.patch"; #P_asb_2022-11 switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/345913.patch"; #P_asb_2022-12 Hide overlay windows when showing phone account enable/disable screen.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/347042.patch"; #P_asb_2023-01 Fix security vulnerability when register phone accounts.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/356150.patch"; #P_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/364617.patch"; #P_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/377776.patch"; #P_asb_2023-12 Resolve account image icon profile boundary exploit.
fi;

if enterAndClear "packages/services/Telephony"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/347041.patch"; #P_asb_2023-01 prevent overlays on the phone settings
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/366130.patch"; #P_asb_2023-09 Fixed leak of cross user data in multiple settings.
git revert --no-edit 99564aaf0417c9ddf7d6aeb10d326e5b24fa8f55;
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch"; #(DivestOS)
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch";
fi;

if enterAndClear "system/bt"; then
applyPatch "$DOS_PATCHES/android_system_bt/334266.patch"; #P_asb_2022-07 Security: Fix out of bound write in HFP client
applyPatch "$DOS_PATCHES/android_system_bt/334267.patch"; #P_asb_2022-07 Check Avrcp packet vendor length before extracting length
applyPatch "$DOS_PATCHES/android_system_bt/334268.patch"; #P_asb_2022-07 Security: Fix out of bound read in AT_SKIP_REST
applyPatch "$DOS_PATCHES/android_system_bt/335109.patch"; #P_asb_2022-08 Removing bonded device when auth fails due to missing keys
applyPatch "$DOS_PATCHES/android_system_bt/338350.patch"; #P_asb_2022-09 Fix OOB in bnep_is_packet_allowed
applyPatch "$DOS_PATCHES/android_system_bt/338351.patch"; #P_asb_2022-09 Fix OOB in BNEP_Write
applyPatch "$DOS_PATCHES/android_system_bt/338352.patch"; #P_asb_2022-09 Fix OOB in reassemble_and_dispatch
applyPatch "$DOS_PATCHES/android_system_bt/342097.patch"; #P_asb_2022-10 Fix potential interger overflow when parsing vendor response
applyPatch "$DOS_PATCHES/android_system_bt/344184.patch"; #P_asb_2022-11 Add negative length check in process_service_search_rsp
applyPatch "$DOS_PATCHES/android_system_bt/344185.patch"; #P_asb_2022-11 Add buffer in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_system_bt/345914.patch"; #P_asb_2022-12 Add length check when copy AVDTP packet
applyPatch "$DOS_PATCHES/android_system_bt/345915.patch"; #P_asb_2022-12 Added max buffer length check
applyPatch "$DOS_PATCHES/android_system_bt/345916.patch"; #P_asb_2022-12 Add missing increment in bnep_api.cc
applyPatch "$DOS_PATCHES/android_system_bt/345917.patch"; #P_asb_2022-12 Add length check when copy AVDT and AVCT packet
applyPatch "$DOS_PATCHES/android_system_bt/345918.patch"; #P_asb_2022-12 Fix integer overflow when parsing avrc response
applyPatch "$DOS_PATCHES/android_system_bt/347127.patch"; #P_asb_2023-01 BT: Once AT command is retrieved, return from method.
applyPatch "$DOS_PATCHES/android_system_bt/347128.patch"; #P_asb_2023-01 AVRC: Validating msg size before accessing fields
applyPatch "$DOS_PATCHES/android_system_bt/349334.patch"; #P_asb_2023-02 Report failure when not able to connect to AVRCP
applyPatch "$DOS_PATCHES/android_system_bt/349335.patch"; #P_asb_2023-02 Add bounds check in avdt_scb_act.cc
applyPatch "$DOS_PATCHES/android_system_bt/351916.patch"; #P_asb_2023-03 Fix an OOB Write bug in gatt_check_write_long_terminate
applyPatch "$DOS_PATCHES/android_system_bt/351917.patch"; #P_asb_2023-03 Fix an OOB access bug in A2DP_BuildMediaPayloadHeaderSbc
applyPatch "$DOS_PATCHES/android_system_bt/351918.patch"; #P_asb_2023-03 Fix an OOB write in SDP_AddAttribute
applyPatch "$DOS_PATCHES/android_system_bt/354246.patch"; #P_asb_2023-04 Fix OOB access in avdt_scb_hdl_pkt_no_frag
applyPatch "$DOS_PATCHES/android_system_bt/354247.patch"; #P_asb_2023-04 Fix an OOB bug in register_notification_rsp
applyPatch "$DOS_PATCHES/android_system_bt/359736.patch"; #P_asb_2023-06 Prevent use-after-free of HID reports
applyPatch "$DOS_PATCHES/android_system_bt/359737.patch"; #P_asb_2023-06 Revert "Revert "Validate buffer length in sdpu_build_uuid_seq""
applyPatch "$DOS_PATCHES/android_system_bt/359738.patch"; #P_asb_2023-06 Revert "Revert "Fix wrong BR/EDR link key downgrades (P_256->P_192)""
applyPatch "$DOS_PATCHES/android_system_bt/361252.patch"; #P_asb_2023-07 Fix gatt_end_operation buffer overflow
applyPatch "$DOS_PATCHES/android_system_bt/366131.patch"; #P_asb_2023-09 Fix an integer overflow bug in avdt_msg_asmbl
applyPatch "$DOS_PATCHES/android_system_bt/366132.patch"; #P_asb_2023-09 Fix integer overflow in build_read_multi_rsp
applyPatch "$DOS_PATCHES/android_system_bt/366133.patch"; #P_asb_2023-09 Fix potential abort in btu_av_act.cc
applyPatch "$DOS_PATCHES/android_system_bt/366134.patch"; #P_asb_2023-09 Fix reliable write.
applyPatch "$DOS_PATCHES/android_system_bt/366135.patch"; #P_asb_2023-09 Fix UAF in gatt_cl.cc
applyPatch "$DOS_PATCHES/android_system_bt/377777.patch"; #P_asb_2023-12 Reject access to secure service authenticated from a temp bonding [1]
applyPatch "$DOS_PATCHES/android_system_bt/377778.patch"; #P_asb_2023-12 Reject access to secure services authenticated from temp bonding [2]
applyPatch "$DOS_PATCHES/android_system_bt/377779.patch"; #P_asb_2023-12 Reject access to secure service authenticated from a temp bonding [3]
applyPatch "$DOS_PATCHES/android_system_bt/377780.patch"; #P_asb_2023-12 Reorganize the code for checking auth requirement
applyPatch "$DOS_PATCHES/android_system_bt/377781.patch"; #P_asb_2023-12 Enforce authentication if encryption is required
applyPatch "$DOS_PATCHES/android_system_bt/377782.patch"; #P_asb_2023-12 Fix timing attack in BTM_BleVerifySignature
applyPatch "$DOS_PATCHES/android_system_bt/377030-backport.patch"; #R_asb_2023-12 Fix OOB Write in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_system_bt/377031.patch"; #R_asb_2023-12 BT: Fixing the rfc_slot_id overflow
applyPatch "$DOS_PATCHES/android_system_bt/379796.patch"; #P_asb_2024-01 Fix some OOB errors in BTM parsing
applyPatch "$DOS_PATCHES/android_system_bt/383565.patch"; #P_asb_2024-02 Fix an OOB bug in btif_to_bta_response and attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/383566.patch"; #P_asb_2024-02 Fix an OOB write bug in attp_build_read_by_type_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/385675.patch"; #P_asb_2024-03 Fix OOB caused by invalid SMP packet length
applyPatch "$DOS_PATCHES/android_system_bt/385676.patch"; #P_asb_2024-03 Fix an OOB bug in smp_proc_sec_req
applyPatch "$DOS_PATCHES/android_system_bt/385677.patch"; #P_asb_2024-03 Reland: Fix an OOB write bug in attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/385678.patch"; #P_asb_2024-03 Fix a security bypass issue in access_secure_service_from_temp_bond
applyPatch "$DOS_PATCHES/android_system_bt/397596.patch"; #P_asb_2024-07 Fix an authentication bypass bug in SMP
applyPatch "$DOS_PATCHES/android_system_bt/399772.patch"; #P_asb_2024-08 Fix heap-buffer overflow in sdp_utils.cc
#applyPatch "$DOS_PATCHES_COMMON/android_system_bt/0001-alloc_size.patch"; #Add alloc_size attributes to the allocator (GrapheneOS)
fi;

if enterAndClear "system/ca-certificates"; then
rm -rf files; #Remove old certs
cp -r "$DOS_PATCHES_COMMON/android_system_ca-certificates/files" .; #Copy the new ones into place
fi;

if enterAndClear "system/core"; then
applyPatch "$DOS_PATCHES/android_system_core/332765.patch"; #P_asb_2022-06 Backport of Win-specific suppression of potentially rogue construct that can engage in directory traversal on the host.
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit b3609d82999d23634c5e6db706a3ecbc5348309a; #Always update recovery
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0002-HM-Increase_vm_mmc.patch"; #(GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0003-Zero_Sensitive_Info.patch"; #Zero sensitive information with explicit_bzero (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_system_core/0004-ptrace_scope.patch"; #Add a property for controlling ptrace_scope (GrapheneOS)
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/libfmq"; then
applyPatch "$DOS_PATCHES_COMMON/android_system_libfmq/399071.patch"; #Q_asb_2024-06 Use the values of the ptrs that we check
fi;

if enterAndClear "system/netd"; then
applyPatch "$DOS_PATCHES/android_system_netd/378480.patch"; #P_asb_2023-12 Fix Heap-use-after-free in MDnsSdListener::Monitor::run
#applyPatch "$DOS_PATCHES/android_system_netd/0001-Fix_DNS_leaks.patch"; #Fix DNS leak in VPN lockdown mode when VPN is down (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_system_netd/0001-Fix_DNS_leaks-relaxed.patch"; #Relax VPN DNS leak prevention for incompatible apps (GrapheneOS)
fi;

if enterAndClear "system/nfc"; then
applyPatch "$DOS_PATCHES/android_system_nfc/332766.patch"; #P_asb_2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_system_nfc/332767.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_system_nfc/332768.patch"; #P_asb_2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
applyPatch "$DOS_PATCHES/android_system_nfc/342098.patch"; #P_asb_2022-10 The length of a packet should be non-zero
applyPatch "$DOS_PATCHES/android_system_nfc/354248.patch"; #P_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_system_nfc/361251.patch"; #P_asb_2023-07 OOBW in rw_i93_send_to_upper()
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #label protected_{fifos,regular} as proc_security (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
git am "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices (DivestOS)
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/28.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/27.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/26.0";
awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
fi;

if enterAndClear "tools/apksig"; then
applyPatch "$DOS_PATCHES/android_tools_apksig/361280.patch"; #P_asb_2023-07 Create source stamp verifier
applyPatch "$DOS_PATCHES/android_tools_apksig/361281.patch"; #P_asb_2023-07 Limit the number of supported v1 and v2 signers
fi;

if enterAndClear "vendor/nxp/opensource/commonsys/external/libnfc-nci"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332769.patch"; #P_asb_2022-06 Prevent OOB write in nfc_ncif_proc_ee_discover_req
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332770.patch"; #P_asb_2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332771.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332772.patch"; #P_asb_2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/342099.patch"; #P_asb_2022-10 The length of a packet should be non-zero
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/354249.patch"; #P_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/361253.patch"; #P_asb_2023-07 OOBW in rw_i93_send_to_upper()
fi;

if enterAndClear "vendor/nxp/opensource/halimpl"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_halimpl/344190.patch"; #P_asb_2022-11 OOBW in phNxpNciHal_write_unlocked()
fi;

if enterAndClear "vendor/nxp/opensource/commonsys/packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/332773.patch"; #P_asb_2022-06 OOB read in phNciNfc_RecvMfResp()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/349336.patch"; #P_asb_2023-02 OOBW in phNciNfc_MfCreateXchgDataHdr
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf verity_tool; #Resurrect dm-verity
rm -rf addonsu;
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/*.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/*.mk; #Remove Lineage extra keys
awk -i inplace '!/WeatherProvider/' config/*.mk; #Remove Weather
awk -i inplace '!/config_multiuserMaximumUsers/' overlay/common/frameworks/base/core/res/res/values/config.xml; #Conflict
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/AudioFX/' config/*.mk; fi; #Remove AudioFX
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/*.mk; #Change buildtype
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
awk -i inplace '!/Eleven/' config/common_mobile.mk; #Remove Music Player
awk -i inplace '!/Exchange2/' config/common_mobile.mk; #Remove Email
cp -f "$DOS_PATCHES_COMMON/config_webview_packages.xml" overlay/common/frameworks/base/core/res/res/xml/config_webview_packages.xml; #Change allowed WebView providers
awk -i inplace '!/com.android.vending/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml; #Remove unwanted apps
awk -i inplace '!/com.google.android/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml;
fi;

if enter "vendor/divested"; then
echo "PRODUCT_PACKAGES += vendor.lineage.trust@1.0-service" >> packages.mk; #Add deny usb service, all of our kernels have the necessary patch
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/wileyfox/kipper"; then
compressRamdisks;
fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf*" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi;
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableEnforceRRO "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio;
removeBuildFingerprints;
hardenLocationSerials || true;
changeDefaultDNS; #Change the default DNS servers
fixupCarrierConfigs || true; #Remove silly carrier restrictions
removeUntrustedCerts || true;
cd "$DOS_BUILD_BASE";

#Tweaks for <2GB RAM devices
#none yet
#Tweaks for <3GB RAM devices
#enableLowRam "device/samsung/kccat6" "kccat6";
#Tweaks for <4GB RAM devices
#enableLowRam "device/samsung/lentislte" "lentislte";
#enableLowRam "device/wileyfox/kipper" "kipper";
#enableLowRam "device/zuk/ham" "ham";

#Fix broken options enabled by hardenDefconfig()
[[ -d kernel/google/yellowstone ]] && sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/yellowstone/arch/arm*/configs/*_defconfig; #Breaks on compile

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l* || true; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
sed -i '117ioutputEntry.setCompressedSize(-1);' external/jarjar/src/main/com/tonicsystems/jarjar/util/IoUtil.java; #Fix compile error
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
