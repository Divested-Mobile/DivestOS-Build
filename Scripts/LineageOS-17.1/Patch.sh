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

if enterAndClear "bootable/recovery"; then
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-No_SerialNum_Restrictions.patch"; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "bionic"; then
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0002-Symbol_Ordering.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_BIONIC" = true ]; then
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-1.patch"; #Add a real explicit_bzero implementation (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-2.patch"; #Replace brk and sbrk with stubs (GrapheneOS) #XXX: some vendor blobs use sbrk
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-3.patch"; #Use blocking getrandom and avoid urandom fallback (GrapheneOS) #XXX: some kernels do not have (working) getrandom
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-4.patch"; #Fix undefined out-of-bounds accesses in sched.h (GrapheneOS)
if [ "$DOS_USE_KSM" = false ]; then applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-5.patch"; fi; #Stop implicitly marking mappings as mergeable (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-6.patch"; #Replace VLA formatting buffer with dprintf (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-7.patch"; #Increase default pthread stack to 8MiB on 64-bit (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-8.patch"; #Make __stack_chk_guard read-only at runtime (GrapheneOS)
applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-9.patch"; #On 64-bit, zero the leading stack canary byte (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-10.patch"; #Switch pthread_atfork handler allocation to mmap (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-11.patch"; #Add memory protection for pthread_atfork handlers (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-12.patch"; #Add memory protection for at_quick_exit (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-13.patch"; #Add XOR mangling mitigation for thread-local dtors (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-14.patch"; #Use a better pthread_attr junk filling pattern (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-15.patch"; #Add guard page(s) between static_tls and stack (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-16.patch"; #Move pthread_internal_t behind guard page (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_bionic/0003-Graphene_Bionic_Hardening-17.patch"; #Add secondary stack randomization (GrapheneOS)
fi;
applyPatch "$DOS_PATCHES/android_bionic/0004-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit 0a9df01b268a238a623f5e0ea5221cebdfee2414; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-Restore_TTS.patch"; #Add back PicoTTS and language files (DivestOS)
applyPatch "$DOS_PATCHES/android_build/0002-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
applyPatch "$DOS_PATCHES/android_build/0003-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_build/0001-verity-openssl3.patch"; #Fix VB 1.0 failure due to openssl output format change
sed -i '75i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
awk -i inplace '!/updatable_apex.mk/' target/product/mainline_system.mk; #Disable APEX
sed -i 's/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 23/PLATFORM_MIN_SUPPORTED_TARGET_SDK_VERSION := 28/' core/version_defaults.mk; #Set the minimum supported target SDK to Pie (GrapheneOS)
#sed -i 's/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := true/PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false/' core/product_config.mk; #broken by hardenDefconfig
sed -i 's/2023-02-05/2024-04-05/' core/version_defaults.mk; #Bump Security String #R_asb_2024-04
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
applyPatch "$DOS_PATCHES/android_build_soong/0002-auto_var_init.patch"; #Enable -ftrivial-auto-var-init=zero (GrapheneOS)
fi;

if enterAndClear "device/qcom/sepolicy-legacy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy-legacy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH (DivestOS)
echo "SELINUX_IGNORE_NEVERALLOWS := true" >> sepolicy.mk; #Ignore neverallow violations XXX: necessary for -user builds of legacy devices
fi;

if enterAndClear "external/aac"; then
applyPatch "$DOS_PATCHES/android_external_aac/365445.patch"; #Q_asb_2023-08 Increase patchParam array size by one and fix out-of-bounce write in resetLppTransposer().
fi;

if enterAndClear "external/chromium-webview"; then
if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then DOS_WEBVIEW_CHERRYPICK; fi; #Update the WebView to latest if available
if [ "$DOS_WEBVIEW_LFS" = true ]; then git lfs pull; fi; #Ensure the objects are available
fi;

if enterAndClear "external/conscrypt"; then
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_external_conscrypt/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "external/freetype"; then
applyPatch "$DOS_PATCHES/android_external_freetype/365406.patch"; #Q_asb_2023-07 Cherry-pick two upstream changes
applyPatch "$DOS_PATCHES/android_external_freetype/365446.patch"; #Q_asb_2023-08 Cherrypick following three changes
applyPatch "$DOS_PATCHES/android_external_freetype/378047.patch"; #Q_asb_2023-12 Make `glyph_name' parameter to `FT_Get_Name_Index' a `const'.
fi;

if [ "$DOS_GRAPHENE_MALLOC" = true ]; then
if enterAndClear "external/hardened_malloc"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc-modern/0001-Broken_Cameras-1.patch"; #Workarounds for Pixel 3 SoC era camera driver bugs (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc-modern/0001-Broken_Cameras-2.patch"; #Expand workaround to all camera executables (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc-modern/0002-Broken_Displays.patch"; #Add workaround for OnePlus 8 & 9 display driver crash (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc-modern/0003-Broken_Audio.patch"; #Workaround for audio service sorting bug (GrapheneOS)
sed -i 's/34359738368/2147483648/' Android.bp; #revert 48-bit address space requirement
sed -i -e '76,78d;' Android.bp; #fix compile under A13
sed -i -e '22,24d;' androidtest/Android.bp; #fix compile under A12
awk -i inplace '!/vendor_ramdisk_available/' Android.bp; #fix compile under A11
rm -rfv androidtest;
sed -i -e '76,78d;' Android.bp; #fix compile under A10
awk -i inplace '!/ramdisk_available/' Android.bp;
git revert --no-edit 8974af86d12f7e29b54b5090133ab3d7eea0e519;
mv include/h_malloc.h  .
fi;
fi;

if enterAndClear "external/libcups"; then
git fetch https://github.com/LineageOS/android_external_libcups refs/changes/95/376595/1 && git cherry-pick FETCH_HEAD; #Q_asb_2023-11 Upgrade libcups to v2.3.1
git fetch https://github.com/LineageOS/android_external_libcups refs/changes/96/376596/1 && git cherry-pick FETCH_HEAD; #Q_asb_2023-11 Upgrade libcups to v2.3.3
fi;

if enterAndClear "external/libvpx"; then
applyPatch "$DOS_PATCHES_COMMON/android_external_libvpx/CVE-2023-5217.patch"; #VP8: disallow thread count changes
fi;

if enterAndClear "external/libxml2"; then
applyPatch "$DOS_PATCHES/android_external_libxml2/368053.patch"; #R_asb_2023-10 malloc-fail: Fix OOB read after xmlRegGetCounter
fi;

if enterAndClear "external/pdfium"; then
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/83/378083/1 && git cherry-pick FETCH_HEAD; #Q_asb_2023-12
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/84/378084/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/85/378085/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/86/378086/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/87/378087/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/88/378088/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/14/378314/1 && git cherry-pick FETCH_HEAD;
git fetch https://github.com/LineageOS/android_external_pdfium refs/changes/15/378315/1 && git cherry-pick FETCH_HEAD;
fi;

if enterAndClear "external/svox"; then
git revert --no-edit 1419d63b4889a26d22443fd8df1f9073bf229d3d; #Add back Makefiles
sed -i '12iLOCAL_SDK_VERSION := current' pico/Android.mk; #Fix build under Pie
sed -i 's/about to delete/unable to delete/' pico/src/com/svox/pico/LangPackUninstaller.java;
awk -i inplace '!/deletePackage/' pico/src/com/svox/pico/LangPackUninstaller.java;
fi;

if enterAndClear "external/zlib"; then
applyPatch "$DOS_PATCHES/android_external_zlib/352570.patch"; #Q_asb_2023-03 Fix a bug when getting a gzip header extra field with inflate().
fi;

if enterAndClear "frameworks/av"; then
applyPatch "$DOS_PATCHES/android_frameworks_av/359385.patch"; #Q_asb_2023-06 Fix NuMediaExtractor::readSampleData buffer Handling
applyPatch "$DOS_PATCHES/android_frameworks_av/368004.patch"; #Q_asb_2023-09 Fix Segv on unknown address error flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/376598.patch"; #Q_asb_2023-11 Fix for heap buffer overflow issue flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/376599.patch"; #Q_asb_2023-11 Fix heap-use-after-free issue flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/378048.patch"; #Q_asb_2023-12 httplive: fix use-after-free
applyPatch "$DOS_PATCHES/android_frameworks_av/380560.patch"; #Q_asb_2024-01 Codec2BufferUtils: Use cropped dimensions in RGB to YUV conversion
applyPatch "$DOS_PATCHES/android_frameworks_av/380561.patch"; #Q_asb_2024-01 Fix convertYUV420Planar16ToY410 overflow issue for unsupported cropwidth.
applyPatch "$DOS_PATCHES/android_frameworks_av/383255.patch"; #Q_asb_2024-02 Update mtp packet buffer
applyPatch "$DOS_PATCHES/android_frameworks_av/391906.patch"; #Q_asb_2024-03 Validate OMX Params for VPx encoders
applyPatch "$DOS_PATCHES/android_frameworks_av/391907.patch"; #Q_asb_2024-03 SoftVideoDecodeOMXComponent: validate OMX params for dynamic HDR
applyPatch "$DOS_PATCHES/android_frameworks_av/391908.patch"; #Q_asb_2024-03 Fix out of bounds read and write in onQueueFilled in outQueue
fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/353117.patch"; #Q_asb_2023-01 Fix sharing to another profile where an app has multiple targets
applyPatch "$DOS_PATCHES/android_frameworks_base/352555.patch"; #Q_asb_2023-03 Revert "Trim the activity info of another uid if no privilege"
applyPatch "$DOS_PATCHES/android_frameworks_base/352556.patch"; #Q_asb_2023-03 Move service initialization
applyPatch "$DOS_PATCHES/android_frameworks_base/352557.patch"; #Q_asb_2023-03 Stop managed profile owner granting READ_SMS
applyPatch "$DOS_PATCHES/android_frameworks_base/352558.patch"; #Q_asb_2023-03 Enable user graularity for lockdown mode
applyPatch "$DOS_PATCHES/android_frameworks_base/352559.patch"; #Q_asb_2023-03 Revoke dev perm if app is upgrading to post 23 and perm has pre23 flag
applyPatch "$DOS_PATCHES/android_frameworks_base/352560.patch"; #Q_asb_2023-03 Reconcile WorkSource parcel and unparcel code.
applyPatch "$DOS_PATCHES/android_frameworks_base/352561.patch"; #Q_asb_2023-03 Revert "Ensure that only SysUI can override pending intent launch flags"
applyPatch "$DOS_PATCHES/android_frameworks_base/355351.patch"; #Q_asb_2023-04 Context#startInstrumentation could be started from SHELL only now.
applyPatch "$DOS_PATCHES/android_frameworks_base/355352.patch"; #Q_asb_2023-04 Checking if package belongs to UID before registering broadcast receiver
applyPatch "$DOS_PATCHES/android_frameworks_base/355353.patch"; #Q_asb_2023-04 Fix checkKeyIntentParceledCorrectly's bypass
applyPatch "$DOS_PATCHES/android_frameworks_base/355354.patch"; #Q_asb_2023-04 Encode Intent scheme when serializing to URI string RESTRICT AUTOMERGE
applyPatch "$DOS_PATCHES/android_frameworks_base/355355.patch"; #Q_asb_2023-04 Backport BAL restrictions from S to R, this blocks apps from using AlarmManager to bypass BAL restrictions.
applyPatch "$DOS_PATCHES/android_frameworks_base/355356.patch"; #Q_asb_2023-04 Strip part of the activity info of another uid if no privilege
applyPatch "$DOS_PATCHES/android_frameworks_base/355357.patch"; #Q_asb_2023-04 Add a limit on channel group creation
applyPatch "$DOS_PATCHES/android_frameworks_base/355358.patch"; #Q_asb_2023-04 Fix bypass BG-FGS and BAL via package manager APIs
applyPatch "$DOS_PATCHES/android_frameworks_base/356352.patch"; #Q_asb_2023-05 [pm] prevent system app downgrades of versions lower than preload
applyPatch "$DOS_PATCHES/android_frameworks_base/356353.patch"; #Q_asb_2023-05 [pm] still allow debuggable for system app downgrades
applyPatch "$DOS_PATCHES/android_frameworks_base/356354.patch"; #Q_asb_2023-05 Checks if AccessibilityServiceInfo is within parcelable size.
applyPatch "$DOS_PATCHES/android_frameworks_base/356355.patch"; #Q_asb_2023-05 Uri: check authority and scheme as part of determining URI path
applyPatch "$DOS_PATCHES/android_frameworks_base/356356.patch"; #Q_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_frameworks_base/359387.patch"; #Q_asb_2023-06 Prevent sharesheet from previewing unowned URIs
applyPatch "$DOS_PATCHES/android_frameworks_base/359388.patch"; #Q_asb_2023-06 Wait for preloading images to complete before inflating notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/359410.patch"; #Q_asb_2023-06 Check key intent for selectors and prohibited flags
applyPatch "$DOS_PATCHES/android_frameworks_base/359411.patch"; #Q_asb_2023-06 Handle invalid data during job loading.
applyPatch "$DOS_PATCHES/android_frameworks_base/378090.patch"; #Q_asb_2023-06 Remove Activity if it enters PiP without window
applyPatch "$DOS_PATCHES/android_frameworks_base/378091.patch"; #Q_asb_2023-06 Prevent RemoteViews crashing SystemUi
applyPatch "$DOS_PATCHES/android_frameworks_base/378092.patch"; #Q_asb_2023-06 Allow filtering of services
applyPatch "$DOS_PATCHES/android_frameworks_base/378093.patch"; #Q_asb_2023-06 Add BubbleMetadata detection to block FSI
applyPatch "$DOS_PATCHES/android_frameworks_base/365409.patch"; #Q_asb_2023-07 Limit the number of supported v1 and v2 signers
applyPatch "$DOS_PATCHES/android_frameworks_base/365410.patch"; #Q_asb_2023-07 Import translations.
applyPatch "$DOS_PATCHES/android_frameworks_base/365411.patch"; #Q_asb_2023-07 Add size check on PPS#policy
applyPatch "$DOS_PATCHES/android_frameworks_base/365412.patch"; #Q_asb_2023-07 Limit the ServiceFriendlyNames
applyPatch "$DOS_PATCHES/android_frameworks_base/365413.patch"; #Q_asb_2023-07 Only allow NEW_TASK flag when adjusting pending intents
applyPatch "$DOS_PATCHES/android_frameworks_base/365414.patch"; #Q_asb_2023-07 Dismiss keyguard when simpin auth'd and...
applyPatch "$DOS_PATCHES/android_frameworks_base/365415.patch"; #Q_asb_2023-07 Increase notification channel limit.
applyPatch "$DOS_PATCHES/android_frameworks_base/365417.patch"; #Q_asb_2023-07 Visit URIs in landscape/portrait custom remote views.
applyPatch "$DOS_PATCHES/android_frameworks_base/378094.patch"; #Q_asb_2023-07 Passpoint Add more check to limit the config size
applyPatch "$DOS_PATCHES/android_frameworks_base/378095.patch"; #Q_asb_2023-07 Sanitize VPN label to prevent HTML injection
applyPatch "$DOS_PATCHES/android_frameworks_base/378096.patch"; #Q_asb_2023-07 Truncate ShortcutInfo Id
applyPatch "$DOS_PATCHES/android_frameworks_base/365447.patch"; #Q_asb_2023-08 ActivityManager#killBackgroundProcesses can kill caller's own app only
applyPatch "$DOS_PATCHES/android_frameworks_base/365448.patch"; #Q_asb_2023-08 ActivityManagerService: Allow openContentUri from vendor/system/product.
applyPatch "$DOS_PATCHES/android_frameworks_base/365450.patch"; #Q_asb_2023-08 On device lockdown, always show the keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/365452.patch"; #Q_asb_2023-08 Implement visitUris for RemoteViews ViewGroupActionAdd.
applyPatch "$DOS_PATCHES/android_frameworks_base/378097.patch"; #Q_asb_2023-08 Verify URI permissions for notification shortcutIcon.
applyPatch "$DOS_PATCHES/android_frameworks_base/365453.patch"; #Q_asb_2023-08 Check URIs in notification public version.
applyPatch "$DOS_PATCHES/android_frameworks_base/365455.patch"; #Q_asb_2023-08 Use Settings.System.getIntForUser instead of getInt to make sure user specific settings are used
applyPatch "$DOS_PATCHES/android_frameworks_base/365457.patch"; #Q_asb_2023-08 Add `PackageParser.Package getPackage(int uid)`
applyPatch "$DOS_PATCHES/android_frameworks_base/378098.patch"; #Q_asb_2023-08 Ensure policy has no absurdly long strings
applyPatch "$DOS_PATCHES/android_frameworks_base/378099.patch"; #Q_asb_2023-08 Verify URI permissions in MediaMetadata
applyPatch "$DOS_PATCHES/android_frameworks_base/378100.patch"; #Q_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_frameworks_base/368007.patch"; #Q_asb_2023-09 Update AccountManagerService checkKeyIntentParceledCorrectly.
applyPatch "$DOS_PATCHES/android_frameworks_base/378101.patch"; #Q_asb_2023-09 Grant carrier privileges if package has carrier config access.
applyPatch "$DOS_PATCHES/android_frameworks_base/378102.patch"; #Q_asb_2023-09 Forbid granting access to NLSes with too-long component names
applyPatch "$DOS_PATCHES/android_frameworks_base/369694.patch"; #Q_asb_2023-10 RingtoneManager: verify default ringtone is audio
applyPatch "$DOS_PATCHES/android_frameworks_base/369695.patch"; #Q_asb_2023-10 Do not share key mappings with JNI object
applyPatch "$DOS_PATCHES/android_frameworks_base/369697.patch"; #Q_asb_2023-10 Fix KCM key mapping cloning
applyPatch "$DOS_PATCHES/android_frameworks_base/369698.patch"; #Q_asb_2023-10 Disallow loading icon from content URI to PipMenu
applyPatch "$DOS_PATCHES/android_frameworks_base/369699.patch"; #Q_asb_2023-10 Fixing DatabaseUtils to detect malformed UTF-16 strings
applyPatch "$DOS_PATCHES/android_frameworks_base/369700.patch"; #Q_asb_2023-10 Revert "Dismiss keyguard when simpin auth'd and..."
applyPatch "$DOS_PATCHES/android_frameworks_base/378104.patch"; #Q_asb_2023-10 Verify URI Permissions in Autofill RemoteViews
applyPatch "$DOS_PATCHES/android_frameworks_base/376600.patch"; #Q_asb_2023-11 Fix BAL via notification.publicVersion
applyPatch "$DOS_PATCHES/android_frameworks_base/376601.patch"; #Q_asb_2023-11 Check caller's uid in backupAgentCreated callback
applyPatch "$DOS_PATCHES/android_frameworks_base/376602.patch"; #Q_asb_2023-11 Use type safe API of readParcelableArray
applyPatch "$DOS_PATCHES/android_frameworks_base/376604.patch"; #Q_asb_2023-11 [SettingsProvider] verify ringtone URI before setting
applyPatch "$DOS_PATCHES/android_frameworks_base/378105.patch"; #Q_asb_2023-11 Make log reader thread a class member
applyPatch "$DOS_PATCHES/android_frameworks_base/378049.patch"; #Q_asb_2023-12 Visit Uris added by WearableExtender
applyPatch "$DOS_PATCHES/android_frameworks_base/378050.patch"; #Q_asb_2023-12 Fix bypass BAL via `requestGeofence`
applyPatch "$DOS_PATCHES/android_frameworks_base/378051.patch"; #Q_asb_2023-12 Make sure we visit the icon URIs of Person objects on Notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/378053.patch"; #Q_asb_2023-12 Drop invalid data.
applyPatch "$DOS_PATCHES/android_frameworks_base/378054.patch"; #Q_asb_2023-12 Validate URI-based shortcut icon at creation time.
applyPatch "$DOS_PATCHES/android_frameworks_base/378055.patch"; #Q_asb_2023-12 Require permission to unlock keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/378056.patch"; #Q_asb_2023-12 Use readUniqueFileDescriptor in incidentd service
applyPatch "$DOS_PATCHES/android_frameworks_base/378057.patch"; #Q_asb_2023-12 Validate userId when publishing shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/378058.patch"; #Q_asb_2023-12 Revert "On device lockdown, always show the keyguard"
applyPatch "$DOS_PATCHES/android_frameworks_base/378059.patch"; #Q_asb_2023-12 Adding in verification of calling UID in onShellCommand
applyPatch "$DOS_PATCHES/android_frameworks_base/378060.patch"; #Q_asb_2023-12 Updated: always show the keyguard on device lockdown
applyPatch "$DOS_PATCHES/android_frameworks_base/378061.patch"; #Q_asb_2023-12 Fix the use of pdfium
applyPatch "$DOS_PATCHES/android_frameworks_base/378106.patch"; #Q_asb_2023-12 Visit Uris related to Notification style extras
applyPatch "$DOS_PATCHES/android_frameworks_base/380562.patch"; #Q_asb_2024-01 Ensure finish lockscreen when usersetup incomplete
applyPatch "$DOS_PATCHES/android_frameworks_base/380563.patch"; #Q_asb_2024-01 Truncate user data to a limit of 500 characters
applyPatch "$DOS_PATCHES/android_frameworks_base/380564.patch"; #Q_asb_2024-01 [CDM] Validate component name length before requesting notification access.
applyPatch "$DOS_PATCHES/android_frameworks_base/380565.patch"; #Q_asb_2024-01 Log to detect usage of whitelistToken when sending non-PI target
applyPatch "$DOS_PATCHES/android_frameworks_base/380566.patch"; #Q_asb_2024-01 Fix vulnerability that allowed attackers to start arbitary activities
applyPatch "$DOS_PATCHES/android_frameworks_base/379136.patch"; #R_asb_2024-01 Fix ActivityManager#killBackgroundProcesses permissions
applyPatch "$DOS_PATCHES/android_frameworks_base/383256.patch"; #Q_asb_2024-02 Disallow Wallpaper service to launch activity from background.
applyPatch "$DOS_PATCHES/android_frameworks_base/383257.patch"; #Q_asb_2024-02 Unbind TileService onNullBinding
applyPatch "$DOS_PATCHES/android_frameworks_base/383258.patch"; #Q_asb_2024-02 Restrict activity launch when caller is running in the background
applyPatch "$DOS_PATCHES/android_frameworks_base/383259.patch"; #Q_asb_2024-02 Check permission of Autofill icon URIs
applyPatch "$DOS_PATCHES/android_frameworks_base/391909.patch"; #Q_asb_2024-03 Resolve custom printer icon boundary exploit.
applyPatch "$DOS_PATCHES/android_frameworks_base/391910.patch"; #Q_asb_2024-03 Add PackageInstaller SessionParams restrictions
applyPatch "$DOS_PATCHES/android_frameworks_base/391911.patch"; #Q_asb_2024-03 Validate package names passed to the installer.
applyPatch "$DOS_PATCHES/android_frameworks_base/391912.patch"; #Q_asb_2024-03 Disallow system apps to be installed/updated as instant.
applyPatch "$DOS_PATCHES/android_frameworks_base/391913.patch"; #Q_asb_2024-03 Close AccountManagerService.session after timeout.
applyPatch "$DOS_PATCHES/android_frameworks_base/389014-backport.patch"; #S_asb_2024-04 Fix security vulnerability that creates user with no restrictions when accountOptions are too long.
applyPatch "$DOS_PATCHES/android_frameworks_base/389269-backport.patch"; #P_asb_2024-04 Close isUserInLockDown can be true when there are other strong auth requirements
#applyPatch "$DOS_PATCHES/android_frameworks_base/272645.patch"; #ten-bt-sbc-hd-dualchannel: Add CHANNEL_MODE_DUAL_CHANNEL constant (ValdikSS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/272646-forwardport.patch"; #ten-bt-sbc-hd-dualchannel: Add Dual Channel into Bluetooth Audio Channel Mode developer options menu (ValdikSS)
#applyPatch "$DOS_PATCHES/android_frameworks_base/272647.patch"; #ten-bt-sbc-hd-dualchannel: Allow SBC as HD audio codec in Bluetooth device configuration (ValdikSS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Always_Restict_Serial.patch"; #Always restrict access to Build.SERIAL (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0008-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0009-SystemUI_No_Permission_Review.patch"; #Allow SystemUI to directly manage Bluetooth/WiFi (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
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
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-12.patch";
applyPatch "$DOS_PATCHES/android_frameworks_base/0010-Exec_Based_Spawning-13.patch";
sed -i 's/sys.spawn.exec/persist.security.exec_spawn_new/' core/java/com/android/internal/os/ZygoteConnection.java;
fi;
applyPatch "$DOS_PATCHES/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after five failed attempts (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0005-User_Logout.patch"; #Allow user logout (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0012-Restore_SensorsOff.patch"; #Restore the Sensors Off tile (DivestOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0013-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Special_Permissions.patch"; #Support new special runtime permissions (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-1.patch"; #Make INTERNET into a special runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-2.patch"; #Add a NETWORK permission group for INTERNET (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-3.patch"; #Enforce INTERNET as a runtime permission. (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-4.patch"; #Fix INTERNET enforcement for secondary users (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-5.patch"; #Send uid for each user instead of just owner/admin user (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Network_Permission-6.patch"; #Skip reportNetworkConnectivity() when permission is revoked (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0014-Sensors_Permission.patch"; #Add special runtime permission for other sensors (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0015-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0016-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0017-WiFi_Timeout.patch"; #Timeout for Wi-Fi (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0018-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0019-Random_MAC.patch"; #Add option of always randomizing MAC addresses (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_base/0020-SUPL_Toggle.patch"; #Add a setting for forcibly disabling SUPL (GrapheneOS)
if [ "$DOS_MICROG_SUPPORT" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0021-Unprivileged_microG_Handling.patch"; fi; #Unprivileged microG handling (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0006-Do-not-throw-in-setAppOnInterfaceLocked.patch"; #Fix random reboots on broken kernels when an app has data restricted XXX: ugly (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0007-ABI_Warning.patch"; #Warn when running activity from 32 bit app on ARM64 devices. (AOSP)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0008-No_Crash_GSF.patch"; #Don't crash apps that depend on missing Gservices provider (GrapheneOS)
if [ "$DOS_SNET" = true ]; then git am "$DOS_PATCHES/android_frameworks_base/snet-17.patch"; fi;
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/wm/ActivityTaskManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
sed -i 's/return 16;/return 64;/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
hardenLocationConf services/core/java/com/android/server/location/gps_debug.conf; #Harden the default GPS config
#rm -rf packages/CompanionDeviceManager; #Used to support Android Wear (which hard depends on GMS)
#sed -i '295i\        if(packageList != null && packageList.size() > 0) { packageList.add("net.sourceforge.opencamera"); }' core/java/android/hardware/Camera.java; #Add Open Camera to aux camera allowlist XXX: needs testing, broke boot last time
rm -rf packages/OsuLogin; #Automatic Wi-Fi connection non-sense
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/355359.patch"; #Q_asb_2023-04 Mitigate the security vulnerability by sanitizing the transaction flags.
applyPatch "$DOS_PATCHES/android_frameworks_native/356357.patch"; #Q_asb_2023-05 Check for malformed Sensor Flattenable
applyPatch "$DOS_PATCHES/android_frameworks_native/356358.patch"; #Q_asb_2023-05 Remove some new memory leaks from SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/356359.patch"; #Q_asb_2023-05 Add removeInstanceForPackageMethod to SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/368009.patch"; #Q_asb_2023-09 Allow sensors list to be empty
applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors.patch"; #Require OTHER_SENSORS permission for sensors (GrapheneOS)
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed (DivestOS)
fi;
fi;

if enterAndClear "frameworks/opt/net/wifi"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/352562.patch"; #Q_asb_2023-03 Revert "wifi: remove certificates for network factory reset"
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/355360.patch"; #Q_asb_2023-04 Revert "Revert "wifi: remove certificates for network factory reset""
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/378139.patch"; #Q_asb_2023-07 Limit the number of Passpoint per App
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_wifi/0002-Random_MAC.patch"; #Add support for always generating new random MAC (GrapheneOS)
fi;

if enterAndClear "hardware/qcom/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory="msm8084"; #(Qualcomm)
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
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8996.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/msm8998/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-8998.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "hardware/qcom-caf/sm8150/audio"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_audio/0001-Unused-sm8150.patch"; #audio_extn: Fix unused parameter warning in utils.c (codeworkx)
fi;

if enterAndClear "libcore"; then
if [ "$DOS_GRAPHENE_EXEC" = true ]; then
applyPatch "$DOS_PATCHES/android_libcore/0001-Exec_Based_Spawning-1.patch"; #Add exec-based spawning support (GrapheneOS)
applyPatch "$DOS_PATCHES/android_libcore/0001-Exec_Based_Spawning-2.patch";
fi;
applyPatch "$DOS_PATCHES/android_libcore/0003-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_libcore/0004-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "lineage-sdk"; then
awk -i inplace '!/LineageWeatherManagerService/' lineage/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Bluetooth"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/378135.patch"; #Q_asb_2023-12 Fix UAF in ~CallbackEnv
#applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/272652.patch"; #ten-bt-sbc-hd-dualchannel: SBC Dual Channel (SBC HD Audio) support (ValdikSS)
#applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/272653.patch"; #ten-bt-sbc-hd-dualchannel: Assume optional codecs are supported if were supported previously (ValdikSS)
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/Camera2"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Camera2/380567.patch"; #Q_asb_2024-01 Camera2: Do not pass location info for startActivity case
fi;

if enterAndClear "packages/apps/Car/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Car_Settings/378111.patch"; #Q_asb_2023-06 Convert argument to Intent in car settings AddAccountActivity.
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
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0005-vCard-Four.patch"; #Add basic support for vCard 4.0 (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/0001-Not_Private_Banner.patch"; #Add a privacy warning banner to calls (CalyxOS)
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Messaging"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Messaging/0001-null-fix.patch"; #Handle null case (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Messaging/0002-missing-channels.patch"; #Add notification channels where missing (LineageOS)
fi;

if enterAndClear "packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/368010.patch"; #Q_asb_2023-09 Ensure that SecureNFC setting cannot be bypassed
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/380568.patch"; #Q_asb_2024-01 Possible deadlock on the NfcService object
if [ "$DOS_GRAPHENE_CONSTIFY" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/0001-constify_JNINativeMethod.patch"; fi; #Constify JNINativeMethod tables (GrapheneOS)
fi;

if enterAndClear "packages/apps/PermissionController"; then
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/352563.patch"; #Q_asb_2023-03 Stop managed profile owner granting READ_SMS
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0001-Network_Permission-1.patch"; #Always treat INTERNET as a runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0001-Network_Permission-2.patch"; #Add INTERNET permission toggle (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0001-Sensors_Permission-1.patch"; #Always treat OTHER_SENSORS as a runtime permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_PermissionController/0001-Sensors_Permission-2.patch"; #Add OTHER_SENSORS permission group (GrapheneOS)
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/352564.patch"; #Q_asb_2023-03 FRP bypass defense in the settings app
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/352565.patch"; #Q_asb_2023-03 Add DISALLOW_APPS_CONTROL check into uninstall app for all users
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/355361.patch"; #Q_asb_2023-04 Only primary user is allowed to control secure nfc
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/359415.patch"; #Q_asb_2023-06 [Settings] Move display of VPN version into summary text
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/378107.patch"; #Q_asb_2023-06 Import translations.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/378108.patch"; #Q_asb_2023-06 Convert argument to intent in AddAccountSettings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/368012.patch"; #Q_asb_2023-09 Prevent non-system IME from becoming device admin
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/378109.patch"; #Q_asb_2023-09 Settings: don't try to allow NLSes with too-long component names
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/378110.patch"; #Q_asb_2023-10 Restrict ApnEditor settings
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/380569.patch"; #Q_asb_2024-01 Validate ringtone URIs before setting
git revert --no-edit 486980cfecce2ca64267f41462f9371486308e9d; #Don't hide OEM unlock
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/272651.patch"; #ten-bt-sbc-hd-dualchannel: Add Dual Channel into Bluetooth Audio Channel Mode developer options menu (ValdikSS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle-gos.patch"; #Add option to disable captive portal checks (GrapheneOS) #FIXME: needs work
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0003-Remove_SensorsOff_Tile.patch"; #Remove the Sensors Off development tile (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0004-Private_DNS.patch"; #More 'Private DNS' options (heavily based off of a CalyxOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Automatic_Reboot.patch"; #Timeout for reboot (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0006-Bluetooth_Timeout.patch"; #Timeout for Bluetooth (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0007-WiFi_Timeout.patch"; #Timeout for Wi-Fi (CalyxOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0008-ptrace_scope.patch"; #Add native debugging setting (GrapheneOS)
if [ "$DOS_GRAPHENE_EXEC" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0009-exec_spawning_toggle.patch"; fi; #Add exec spawning toggle (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0010-Random_MAC-1.patch"; #Add option to always randomize MAC (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0010-Random_MAC-2.patch"; #Remove partial MAC randomization translations (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0011-LTE_Only_Mode.patch"; #Add LTE-only option (GrapheneOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0012-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0013-SUPL_Toggle.patch"; #Add a toggle for forcibly disabling SUPL (GrapheneOS)
if [ "$DOS_MICROG_SUPPORT" = true ]; then applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0014-microG_Toggle.patch"; fi; #Add a toggle for microG enablement (heavily based off of a GrapheneOS patch)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Settings/0001-disable_apps.patch"; #Add an ability to disable non-system apps from the "App info" screen (GrapheneOS)
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 64;/' src/com/android/settings/password/ChooseLockPassword.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/Traceur"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/359418.patch"; #Q_asb_2023-06 Block Traceur MainTvActivity when development options disabled.
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/359419.patch"; #Q_asb_2023-06 Initialize developer options ContentObserver at app start
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/378119.patch"; #Q_asb_2023-06 Update Traceur to check admin user status
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/359421.patch"; #Q_asb_2023-06 Add DISALLOW_DEBUGGING_FEATURES check
fi;

if enterAndClear "packages/apps/Trebuchet"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/368013.patch"; #Q_asb_2023-09 Fix permission issue in legacy shortcut
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/378063.patch"; #Q_asb_2023-12 Fix permission bypass in legacy shortcut
cp $DOS_BUILD_BASE/vendor/divested/overlay/common/packages/apps/Trebuchet/res/xml/default_workspace_*.xml res/xml/; #XXX: Likely no longer needed
fi;

if enterAndClear "packages/apps/TvSettings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_TvSettings/359422.patch"; #Q_asb_2023-06 Convert argument to intent in addAccount TvSettings.
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

#if enterAndClear "packages/modules/NetworkStack"; then
#applyPatch "$DOS_PATCHES/android_packages_modules_NetworkStack/0001-Random_MAC.patch"; #Avoid reusing DHCP state for full MAC randomization (GrapheneOS) #FIXME: DhcpClient.java:960: error: cannot find symbol
#fi;

if enterAndClear "packages/providers/DownloadProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
fi;

if enterAndClear "packages/providers/MediaProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_MediaProvider/355362.patch"; #Q_asb_2023-04 Canonicalise path before extracting relative path
applyPatch "$DOS_PATCHES/android_packages_providers_MediaProvider/378137.patch"; #Q_asb_2023-09 Canonicalize file path for insertion by legacy apps
applyPatch "$DOS_PATCHES/android_packages_providers_MediaProvider/378138.patch"; #Q_asb_2023-10 Fix path traversal vulnerabilities in MediaProvider
fi;

if enterAndClear "packages/providers/TelephonyProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/365458.patch"; #Q_asb_2023-08 Update file permissions using canonical path
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/376605.patch"; #Q_asb_2023-11 Block access to sms/mms db from work profile.
#cp $DOS_PATCHES_COMMON/android_packages_providers_TelephonyProvider/carrier_list.* assets/;
fi;

if enterAndClear "packages/services/BuiltInPrintService"; then
applyPatch "$DOS_PATCHES/android_packages_services_BuiltInPrintService/376606.patch"; #Q_asb_2023-11 Adjust APIs for CUPS 2.3.3
fi

if enterAndClear "packages/services/Telecomm"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/355363.patch"; #Q_asb_2023-04 Ensure service unbind when receiving a null call screening service in onBind.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/355364.patch"; #Q_asb_2023-04 do not process content uri in call Intents
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/356360.patch"; #Q_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/378120.patch"; #Q_asb_2023-06 Call Redirection: unbind service when onBind returns null
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/378122.patch"; #Q_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/369703.patch"; #Q_asb_2023-12 Fix vulnerability in CallRedirectionService.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/378123.patch"; #Q_asb_2023-12 Support for API cleanups.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/378065.patch"; #Q_asb_2023-12 Resolve account image icon profile boundary exploit.
fi;

if enterAndClear "packages/services/Telephony"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/368015.patch"; #Q_asb_2023-09 Grant carrier privileges if package has carrier config access.
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/378161.patch"; #Q_asb_2023-09 Fixed leak of cross user data in multiple settings.
fi

if enterAndClear "prebuilts/abi-dumps/vndk"; then
applyPatch "$DOS_PATCHES/android_prebuilts_abi-dumps_vndk/0001-protobuf-avi.patch"; #Work around ABI changes from compiler hardening (GrapheneOS)
fi;

if enterAndClear "system/bt"; then
applyPatch "$DOS_PATCHES/android_system_bt/352276.patch"; #Q_asb_2023-03 Fix an OOB Write bug in gatt_check_write_long_terminate
applyPatch "$DOS_PATCHES/android_system_bt/352277.patch"; #Q_asb_2023-03 Fix an OOB access bug in A2DP_BuildMediaPayloadHeaderSbc
applyPatch "$DOS_PATCHES/android_system_bt/352278.patch"; #Q_asb_2023-03 Fix an OOB write in SDP_AddAttribute
applyPatch "$DOS_PATCHES/android_system_bt/355365.patch"; #Q_asb_2023-04 Fix OOB access in avdt_scb_hdl_pkt_no_frag
applyPatch "$DOS_PATCHES/android_system_bt/355366.patch"; #Q_asb_2023-04 Fix an OOB bug in register_notification_rsp
applyPatch "$DOS_PATCHES/android_system_bt/359424.patch"; #Q_asb_2023-06 Prevent use-after-free of HID reports
applyPatch "$DOS_PATCHES/android_system_bt/359425.patch"; #Q_asb_2023-06 Revert "Revert "Validate buffer length in sdpu_build_uuid_seq""
applyPatch "$DOS_PATCHES/android_system_bt/359426.patch"; #Q_asb_2023-06 Revert "Revert "Fix wrong BR/EDR link key downgrades (P_256->P_192)""
applyPatch "$DOS_PATCHES/android_system_bt/365419.patch"; #Q_asb_2023-07 Fix gatt_end_operation buffer overflow
applyPatch "$DOS_PATCHES/android_system_bt/368017.patch"; #Q_asb_2023-09 Fix an integer overflow bug in avdt_msg_asmbl
applyPatch "$DOS_PATCHES/android_system_bt/368018.patch"; #Q_asb_2023-09 Fix integer overflow in build_read_multi_rsp
applyPatch "$DOS_PATCHES/android_system_bt/368019.patch"; #Q_asb_2023-09 Fix potential abort in btu_av_act.cc
applyPatch "$DOS_PATCHES/android_system_bt/368020.patch"; #Q_asb_2023-09 Fix UAF in gatt_cl.cc
applyPatch "$DOS_PATCHES/android_system_bt/378066.patch"; #Q_asb_2023-12 Reject access to secure service authenticated from a temp bonding [1]
applyPatch "$DOS_PATCHES/android_system_bt/378067.patch"; #Q_asb_2023-12 Reject access to secure services authenticated from temp bonding [2]
applyPatch "$DOS_PATCHES/android_system_bt/378068.patch"; #Q_asb_2023-12 Reject access to secure service authenticated from a temp bonding [3]
applyPatch "$DOS_PATCHES/android_system_bt/378069.patch"; #Q_asb_2023-12 Reorganize the code for checking auth requirement
applyPatch "$DOS_PATCHES/android_system_bt/378070.patch"; #Q_asb_2023-12 Enforce authentication if encryption is required
applyPatch "$DOS_PATCHES/android_system_bt/378072.patch"; #Q_asb_2023-12 Fix `find_rfc_slot_by_pending_sdp` not finding active slot with max ID
applyPatch "$DOS_PATCHES/android_system_bt/378073.patch"; #Q_asb_2023-12 Fix OOB Write in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_system_bt/378089.patch"; #Q_asb_2023-12 Fix timing attack in BTM_BleVerifySignature
applyPatch "$DOS_PATCHES/android_system_bt/380570.patch"; #Q_asb_2024-01 Fix some OOB errors in BTM parsing
applyPatch "$DOS_PATCHES/android_system_bt/383260.patch"; #Q_asb_2024-02 Fix an OOB bug in btif_to_bta_response and attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/383261.patch"; #Q_asb_2024-02 Fix an OOB write bug in attp_build_read_by_type_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/391914.patch"; #Q_asb_2024-03 Fix an OOB bug in smp_proc_sec_req
applyPatch "$DOS_PATCHES/android_system_bt/391915.patch"; #Q_asb_2024-03 Reland: Fix an OOB write bug in attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/391916.patch"; #Q_asb_2024-03 Fix a security bypass issue in access_secure_service_from_temp_bond
applyPatch "$DOS_PATCHES_COMMON/android_system_bt/0001-alloc_size.patch"; #Add alloc_size attributes to the allocator (GrapheneOS)
#applyPatch "$DOS_PATCHES/android_system_bt/272648.patch"; #ten-bt-sbc-hd-dualchannel: Increase maximum Bluetooth SBC codec bitrate for SBC HD (ValdikSS)
#applyPatch "$DOS_PATCHES/android_system_bt/272649.patch"; #ten-bt-sbc-hd-dualchannel: Explicit SBC Dual Channel (SBC HD) support (ValdikSS)
#applyPatch "$DOS_PATCHES/android_system_bt/272650.patch"; #ten-bt-sbc-hd-dualchannel: Allow using alternative (higher) SBC HD bitrates with a property (ValdikSS)
fi;

if enterAndClear "system/ca-certificates"; then
rm -rf files; #Remove old certs
cp -r "$DOS_PATCHES_COMMON/android_system_ca-certificates/files" .; #Copy the new ones into place
fi;

if enterAndClear "system/core"; then
applyPatch "$DOS_PATCHES/android_system_core/383262.patch"; #Q_asb_2024-02 Add seal if ashmem-dev is backed by memfd
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 3032c7aa5ce90c0ae9c08fe271052c6e0304a1e7 01266f589e6deaef30b782531ae14435cdd2f18e; #insanity
git revert --no-edit bd4142eab8b3cead0c25a2e660b4b048d1315d3c; #Always update recovery
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
if [ "$DOS_GRAPHENE_MALLOC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0002-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
if [ "$DOS_GRAPHENE_BIONIC" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0003-Zero_Sensitive_Info.patch"; fi; #Zero sensitive information with explicit_bzero (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_core/0004-ptrace_scope.patch"; #Add a property for controlling ptrace_scope (GrapheneOS)
if [ "$DOS_SNET_EXTRA" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/snet-17.patch"; fi;
fi;

if enterAndClear "system/extras"; then
applyPatch "$DOS_PATCHES/android_system_extras/0001-ext4_pad_filenames.patch"; #FBE: pad filenames more (GrapheneOS)
fi;

if enterAndClear "system/netd"; then
applyPatch "$DOS_PATCHES/android_system_netd/376607.patch"; #Q_asb_2023-11 Fix use-after-free in DNS64 discovery thread
applyPatch "$DOS_PATCHES/android_system_netd/378074.patch"; #Q_asb_2023-12 Fix Heap-use-after-free in MDnsSdListener::Monitor::run
applyPatch "$DOS_PATCHES/android_system_netd/0001-Network_Permission.patch"; #Expose the NETWORK permission (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_netd/0002-hosts_toggle.patch"; #Add a toggle to disable /etc/hosts lookup (DivestOS)
fi;

if enterAndClear "system/nfc"; then
applyPatch "$DOS_PATCHES/android_system_nfc/355367.patch"; #Q_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_system_nfc/365420.patch"; #Q_asb_2023-07 OOBW in rw_i93_send_to_upper()
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #label protected_{fifos,regular} as proc_security (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-1.patch"; #Allow init to control kernel.yama.ptrace_scope (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0003-ptrace_scope-2.patch"; #Allow system to use persist.native_debug (GrapheneOS)
git am "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices (DivestOS)
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/29.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/28.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/27.0";
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/26.0";
awk -i inplace '!/true cannot be used in user builds/' Android.mk; #Allow ignoring neverallows under -user
fi;

if enterAndClear "system/update_engine"; then
git revert --no-edit c68499e3ff10f2a31f913e14f66aafb4ed94d42d; #Do not skip payload signature verification
fi;

if enterAndClear "tools/apksig"; then
applyPatch "$DOS_PATCHES/android_tools_apksig/376559.patch"; #Q_asb_2023-07 Limit the number of supported v1 and v2 signers

fi;

if enterAndClear "vendor/nxp/opensource/commonsys/external/libnfc-nci"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/355368.patch"; #Q_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/378160.patch"; #Q_asb_2023-07 OOBW in rw_i93_send_to_upper()
fi;

if enterAndClear "vendor/nxp/opensource/pn5xx/halimpl"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_halimpl/355369.patch"; #Q_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
fi;

if enterAndClear "vendor/nxp/opensource/commonsys/packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/378163.patch"; #Q_asb_2023-09 Ensure that SecureNFC setting cannot be bypassed
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/380571.patch"; #Q_asb_2024-01 Possible deadlock on the NfcService object
fi;

if enterAndClear "vendor/qcom/opensource/commonsys/packages/apps/Bluetooth"; then
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_packages_apps_Bluetooth/378136.patch"; #Q_asb_2023-12 Fix UAF in ~CallbackEnv
fi;

if enterAndClear "vendor/qcom/opensource/commonsys/system/bt"; then
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/352566.patch"; #Q_asb_2023-03 Fix an OOB Write bug in gatt_check_write_long_terminate
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/352567.patch"; #Q_asb_2023-03 Fix an OOB access bug in A2DP_BuildMediaPayloadHeaderSbc
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/352568.patch"; #Q_asb_2023-03 Fix an OOB write in SDP_AddAttribute
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/352569.patch"; #Q_asb_2023-03 AVRCP: Fix potential buffer overflow
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/355370.patch"; #Q_asb_2023-04 Fix an OOB bug in register_notification_rsp
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/355371.patch"; #Q_asb_2023-04 AVDTP: Fix a potential overflow about the media payload offset
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/365442.patch"; #Q_asb_2023-06 Fix gatt_end_operation buffer overflow
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378124.patch"; #Q_asb_2023-06 Revert "Revert "Fix wrong BR/EDR link key downgrades (P_256->P_192)""
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378125.patch"; #Q_asb_2023-06 Prevent use-after-free of HID reports
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378126.patch"; #Q_asb_2023-06 Revert^2 "Validate buffer length in sdpu_build_uuid_seq"
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/368022.patch"; #Q_asb_2023-12 Fix an integer overflow bug in avdt_msg_asmbl
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/368023.patch"; #Q_asb_2023-12 Fix integer overflow in build_read_multi_rsp
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/368024.patch"; #Q_asb_2023-12 Fix potential abort in btu_av_act.cc
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/368025.patch"; #Q_asb_2023-12 Fix UAF in gatt_cl.cc
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378077.patch"; #Q_asb_2023-12 Reject access to secure services authenticated from temp bonding [2]
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378078.patch"; #Q_asb_2023-12 Reject access to secure service authenticated from a temp bonding [3]
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378079.patch"; #Q_asb_2023-12 Fix OOB Write in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378080.patch"; #Q_asb_2023-12 BT: Fixing the rfc_slot_id overflow
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378082.patch"; #Q_asb_2023-12 Fix `find_rfc_slot_by_pending_sdp` not finding active slot with max ID
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378133.patch"; #Q_asb_2023-12 Reject access to secure service authenticated from a temp bonding [1]
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/378134.patch"; #Q_asb_2023-12 Fix timing attack in BTM_BleVerifySignature
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/380572.patch"; #Q_asb_2024-01 Fix some OOB errors in BTM parsing
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/383263.patch"; #Q_asb_2024-02 Fix an OOB bug in btif_to_bta_response and attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/383264.patch"; #Q_asb_2024-02 Fix an OOB write bug in attp_build_read_by_type_value_cmd
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/391917.patch"; #Q_asb_2024-03 Fix an OOB bug in smp_proc_sec_req
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/391918.patch"; #Q_asb_2024-03 Fix a security bypass issue in access_secure_service_from_temp_bond
applyPatch "$DOS_PATCHES/android_vendor_qcom_opensource_system_bt/391919.patch"; #Q_asb_2024-03 Reland: Fix an OOB write bug in attp_build_value_cmd
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
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
awk -i inplace '!/Email/' config/common_mobile.mk; #Remove Email
awk -i inplace '!/Exchange2/' config/common_mobile.mk;
cp -f "$DOS_PATCHES_COMMON/config_webview_packages.xml" overlay/common/frameworks/base/core/res/res/xml/config_webview_packages.xml; #Change allowed WebView providers
awk -i inplace '!/com.android.vending/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml; #Remove unwanted apps
awk -i inplace '!/com.google.android/' overlay/common/frameworks/base/core/res/res/values/vendor_required_apps*.xml;
fi;

if enter "vendor/divested"; then
echo "PRODUCT_PACKAGES += vendor.lineage.trust@1.0-service" >> packages.mk; #Add deny usb service, all of our kernels have the necessary patch
awk -i inplace '!/speed-profile/' build/target/product/lowram.mk; #breaks compile on some dexpreopt devices
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

if enterAndClear "device/motorola/clark"; then
echo "allow mm-qcamerad camera_prop:property_service set;" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad property_socket:sock_file write;" >> sepolicy/mm-qcamerad.te;
echo "allow mm-qcamerad camera_prop:file read;" >> sepolicy/mm-qcamerad.te;
echo "set_prop(mm-qcamerad, camera_prop)" >> sepolicy/mm-qcamerad.te;
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

if enterAndClear "device/xiaomi/davinci"; then
smallerSystem;
fi;

if enterAndClear "device/xiaomi/sm6150-common"; then
smallerSystem;
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
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'disableAPEX "{}"';
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

#Tweaks for <2GB RAM devices
enableLowRam "device/motorola/harpia" "harpia";
enableLowRam "device/motorola/merlin" "merlin";
enableLowRam "device/motorola/msm8916-common" "msm8916-common";
enableLowRam "device/motorola/osprey" "osprey";
enableLowRam "device/motorola/surnia" "surnia";
#Tweaks for <3GB RAM devices
enableLowRam "device/cyanogen/msm8916-common" "msm8916-common";
enableLowRam "device/wileyfox/crackling" "crackling";
#Tweaks for 3GB/4GB RAM devices
#enableLowRam "device/oneplus/oneplus2" "oneplus2";

#Fix broken options enabled by hardenDefconfig()
#none yet

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l* || true; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
sed -i '117ioutputEntry.setCompressedSize(-1);' external/jarjar/src/main/com/tonicsystems/jarjar/util/IoUtil.java; #Fix compile error
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
