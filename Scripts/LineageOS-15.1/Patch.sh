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

if enterAndClear "bionic"; then
applyPatch "$DOS_PATCHES_COMMON/android_bionic/0001-Wildcard_Hosts.patch"; #Support wildcards in cached hosts file (backport from 16.0+) (tdm)
#if [ "$DOS_GRAPHENE_MALLOC_BROKEN" = true ]; then applyPatch "$DOS_PATCHES/android_bionic/0001-HM-Use_HM.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "bootable/recovery"; then
git revert --no-edit eb98fde70a6e54a25408eb8c626caecf7841c5df; #Remove sideload cache, breaks with large files
git revert --no-edit ac258a4f4c4b4b91640cc477ad1ac125f206db02; #Resurrect dm-verity
sed -i 's/!= 2048/< 2048/' tools/dumpkey/DumpPublicKey.java; #Allow 4096-bit keys
sed -i 's/(!has_serial_number || serial_number_matched)/!has_serial_number/' recovery.cpp; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build/make"; then
git revert --no-edit ceb64cd86b1cf6be3b1214ace80d8260971f8877; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
applyPatch "$DOS_PATCHES/android_build/0002-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
sed -i '57i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
if [ "$DOS_SILENCE_INCLUDED" = true ]; then sed -i 's/messaging/Silence/' target/product/aosp_base_telephony.mk target/product/treble_common.mk; fi; #Replace the Messaging app with Silence
awk -i inplace '!/Email/' target/product/core.mk; #Remove Email
sed -i 's/2021-10-05/2022-09-05/' core/version_defaults.mk; #Bump Security String #XXX
fi;

if enterAndClear "build/soong"; then
applyPatch "$DOS_PATCHES/android_build_soong/0001-Enable_fwrapv.patch"; #Use -fwrapv at a minimum (GrapheneOS)
fi;

if enterAndClear "device/lineage/sepolicy"; then
git revert --no-edit 9c28a0dfb91bb468515e123b1aaf3fcfc007b82f; #neverallow violation - breaks backuptool
git revert --no-edit f1ad32105599a0b71702f840b2deeb6849f1ae80; #neverallow violation - breaks addons
git revert --no-edit c9b0d95630b82cd0ad1a0fc633c6d59c2cb8aad7 37422f7df389f3ae5a34ee3d6dd9354217f9c536; #neverallow violation - breaks update_engine
fi;

if enterAndClear "device/qcom/sepolicy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy/0001-Camera_Fix.patch"; #Fix camera on -user builds XXX: REMOVE THIS TRASH (DivestOS)
fi;

if enterAndClear "external/chromium-webview"; then
if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then DOS_WEBVIEW_CHERRYPICK; fi; #Update the WebView to latest if available
if [ "$DOS_WEBVIEW_LFS" = true ]; then git lfs pull; fi; #Ensure the objects are available
fi;

if enterAndClear "external/expat"; then
applyPatch "$DOS_PATCHES/android_external_expat/337987.patch"; #Q_asb_2022-09 Prevent XML_GetBuffer signed integer overflow
applyPatch "$DOS_PATCHES/android_external_expat/337988-backport.patch"; #n-asb-2022-09 Prevent integer overflow in function doProlog
applyPatch "$DOS_PATCHES/android_external_expat/337989-backport.patch"; #n-asb-2022-09 Prevent more integer overflows
fi;

#if [ "$DOS_GRAPHENE_MALLOC_BROKEN" = true ]; then
#if enterAndClear "external/hardened_malloc"; then
#applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0001-Broken_Audio.patch"; #DeviceDescriptor sorting wrongly relies on malloc addresses (GrapheneOS)
#applyPatch "$DOS_PATCHES_COMMON/android_external_hardened_malloc/0002-Broken_Cameras.patch"; #Expand workaround to all camera executables (DivestOS)
#fi;
#fi;

if enterAndClear "external/svox"; then
git revert --no-edit 1419d63b4889a26d22443fd8df1f9073bf229d3d; #Add back Makefiles
fi;

#if enterAndClear "frameworks/av"; then
#if [ "$DOS_GRAPHENE_MALLOC_BROKEN" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_av/0001-HM-No_RLIMIT_AS.patch"; fi; #(GrapheneOS)
#fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/330961-backport.patch"; #P_asb_2022-05 Keyguard - Treat messsages to lock with priority
applyPatch "$DOS_PATCHES/android_frameworks_base/331108.patch"; #n-asb-2022-05 Always restart apps if base.apk gets updated.
applyPatch "$DOS_PATCHES/android_frameworks_base/332449.patch"; #n-asb-2022-06 Add an OEM configurable limit for zen rules
applyPatch "$DOS_PATCHES/android_frameworks_base/332757.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10; api doc update
applyPatch "$DOS_PATCHES/android_frameworks_base/332776.patch"; #P_asb_2022-06 Update GeofenceHardwareRequestParcelable to match parcel/unparcel format.
applyPatch "$DOS_PATCHES/android_frameworks_base/332778.patch"; #P_asb_2022-06 Fix security hole in GateKeeperResponse
applyPatch "$DOS_PATCHES/android_frameworks_base/332779.patch"; #P_asb_2022-06 Prevent non-admin users from deleting system apps.
#applyPatch "$DOS_PATCHES/android_frameworks_base/334257-backport.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery if preparing user storage fails #XXX
#applyPatch "$DOS_PATCHES/android_frameworks_base/334258-backport.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery for system user only #XXX
applyPatch "$DOS_PATCHES/android_frameworks_base/334262.patch"; #P_asb_2022-07 Crash invalid FGS notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/335117-backport.patch"; #P_asb_2022-08 Only allow system and same app to apply relinquishTaskIdentity
#applyPatch "$DOS_PATCHES/android_frameworks_base/335119.patch"; #P_asb_2022-08 Remove package title from notification access confirmation intent TODO: 335116 must be backported
applyPatch "$DOS_PATCHES/android_frameworks_base/335120.patch"; #P_asb_2022-08 Stop using invalid URL to prevent unexpected crash
applyPatch "$DOS_PATCHES/android_frameworks_base/335121-backport.patch"; #P_asb_2022-08 Only allow the system server to connect to sync adapters
#applyPatch "$DOS_PATCHES/android_frameworks_base/337990.patch"; #Q_asb_2022-09 Fix duplicate permission privilege escalation #XXX: needs getProtection() backport
applyPatch "$DOS_PATCHES/android_frameworks_base/337991.patch"; #Q_asb_2022-09 Parcel: recycle recycles
applyPatch "$DOS_PATCHES/android_frameworks_base/337992-backport.patch"; #Q_asb_2022-09 IMMS: Make IMMS PendingIntents immutable
#applyPatch "$DOS_PATCHES/android_frameworks_base/337993.patch"; #Q_asb_2022-09 Remove package name from SafetyNet logs #XXX: depends on 337990
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0001-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0004-Fingerprint_Lockout.patch"; #Enable fingerprint lockout after three failed attempts (GrapheneOS)
if [ "$DOS_SENSORS_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0007-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/DEFAULT_MAX_FILES_LOWRAM = 300;/DEFAULT_MAX_FILES_LOWRAM = 0;/' services/core/java/com/android/server/DropBoxManagerService.java;
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/return 16;/return 64;/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
sed -i 's/entry == null/entry == null || true/' core/java/android/os/RecoverySystem.java; #Skip strict update compatibiltity checks XXX: TEMPORARY FIX
sed -i 's/!Build.isBuildConsistent()/false/' services/core/java/com/android/server/am/ActivityManagerService.java; #Disable partition fingerprint mismatch warnings XXX: TEMPORARY FIX
hardenLocationFWB "$DOS_BUILD_BASE"; #Harden the default GPS config
changeDefaultDNS; #Change the default DNS servers
if [ "$DOS_MICROG_INCLUDED" != "FULL" ]; then rm -rf packages/CompanionDeviceManager; fi; #Used to support Android Wear (which hard depends on GMS)
rm -rf packages/Osu packages/Osu2; #Automatic Wi-Fi connection non-sense
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/326752.patch"; #P_asb_2022-03 Check if the window is partially obscured for slippery enters
if [ "$DOS_SENSORS_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_native/0001-Sensors.patch"; fi; #Permission for sensors access (MSe1969)
fi;

if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
if enterAndClear "frameworks/opt/net/ims"; then
applyPatch "$DOS_PATCHES/android_frameworks_opt_net_ims/0001-Fix_Calling.patch"; #Fix calling when IMS is removed (DivestOS)
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

if enterAndClear "hardware/qcom/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory="msm8084"; #(Qualcomm)
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch" --directory="msm8226";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch" --directory="msm8960";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch" --directory="msm8974";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch" --directory="msm8994";
#TODO: missing msm8909, msm8996, msm8998, sdm845
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

if enterAndClear "hardware/qcom/gps"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_gps/0001-rollover.patch"; #Fix week rollover (jlask)
fi;

if enterAndClear "lineage-sdk"; then
awk -i inplace '!/WeatherManagerServiceBroker/' lineage/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/LineageAudioService/' lineage/res/res/values/config.xml; fi; #Remove AudioFX
fi;

if enterAndClear "packages/apps/Bluetooth"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332758-backport.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setScanMode by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332759-backport.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setDiscoverableTimeout by requiring BLUETOOTH_PRIVILEGED permission.
fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/332760.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0001-No_Google_Links.patch"; #Remove Privacy Policy and Terms of Service links (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0003-Skip_Accounts.patch"; #Don't prompt to add account when creating a contact (CalyxOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0004-No_GMaps.patch"; #Use common intent for directions instead of Google Maps URL (GrapheneOS)
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/332761.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
fi;

if enterAndClear "packages/apps/KeyChain"; then
applyPatch "$DOS_PATCHES/android_packages_apps_KeyChain/334264.patch"; #P_asb_2022-07 Encode authority part of uri before showing in UI
fi;

if enterAndClear "packages/apps/LineageParts"; then
rm -rf src/org/lineageos/lineageparts/lineagestats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of the analytics
applyPatch "$DOS_PATCHES/android_packages_apps_LineageParts/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/328346.patch"; #P_asb_2022-04 Do not set default contactless application without user interaction
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/332455-backport.patch"; #n-asb-2022-06 OOB read in phNciNfc_RecvMfResp()
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/326758.patch"; #P_asb_2022-03 Fix bypass CALL_PRIVILEGED permission in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/326759.patch"; #P_asb_2022-03 Add caller check to com.android.credentials.RESET
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/327099.patch"; #n-asb-2022-03 Add caller check to com.android.credentials.RESET
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/332763.patch"; #P_asb_2022-06 Prevent exfiltration of system files via user image settings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334265.patch"; #P_asb_2022-07 Fix LaunchAnyWhere in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335111.patch"; #P_asb_2022-08 Verify ringtone from ringtone picker is audio
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335114.patch"; #P_asb_2022-08 Fix Settings crash when setting a null ringtone
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335115.patch"; #P_asb_2022-08 Fix can't change notification sound for work profile.
#applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335116.patch"; #P_asb_2022-08 Extract app label from component name in notification access confirmation UI #TODO: needs backport
git revert --no-edit a96df110e84123fe1273bff54feca3b4ca484dcd; #Don't hide OEM unlock
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
if [ "$DOS_SENSORS_PERM" = true ]; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Sensors-P1.patch"; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0005-Sensors-P2.patch";
fi;
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 64;/' src/com/android/settings/password/ChooseLockPassword.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove analytics (DivestOS)
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
#TODO: Remove changelog
fi;

if enterAndClear "packages/apps/WallpaperPicker"; then
#TODO: Add back wallpapers
sed -i 's/req.touchEnabled = touchEnabled;/req.touchEnabled = true;/' src/com/android/wallpaperpicker/WallpaperCropActivity.java; #Allow scrolling
sed -i 's/mCropView.setTouchEnabled(req.touchEnabled);/mCropView.setTouchEnabled(true);/' src/com/android/wallpaperpicker/WallpaperCropActivity.java;
sed -i 's/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0);/WallpaperUtils.EXTRA_WALLPAPER_OFFSET, 0.5f);/' src/com/android/wallpaperpicker/WallpaperPickerActivity.java; #Center aligned by default
fi;

if enterAndClear "packages/inputmethods/LatinIME"; then
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/providers/ContactsProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_ContactsProvider/335110.patch"; #P_asb_2022-08 enforce stricter CallLogProvider query
fi;

if enterAndClear "packages/providers/MediaProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_MediaProvider/0001-External_Permission.patch"; #Fix permission denial (luca.stefani)
fi;

if enterAndClear "packages/services/Telecomm"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/332764.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10
fi;

if enterAndClear "packages/services/Telephony"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch"; #(DivestOS)
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch";
fi;

if enterAndClear "system/bt"; then
applyPatch "$DOS_PATCHES/android_system_bt/328347.patch"; #P_asb_2022-04 Security fix OOB read due to invalid count in stack/avrc/avrc_pars_ct
applyPatch "$DOS_PATCHES/android_system_bt/334266.patch"; #P_asb_2022-07 Security: Fix out of bound write in HFP client
applyPatch "$DOS_PATCHES/android_system_bt/334267.patch"; #P_asb_2022-07 Check Avrcp packet vendor length before extracting length
applyPatch "$DOS_PATCHES/android_system_bt/334268.patch"; #P_asb_2022-07 Security: Fix out of bound read in AT_SKIP_REST
applyPatch "$DOS_PATCHES/android_system_bt/335109.patch"; #P_asb_2022-08 Removing bonded device when auth fails due to missing keys
applyPatch "$DOS_PATCHES/android_system_bt/337995-backport.patch"; #Q_asb_2022-09 Fix OOB in bnep_is_packet_allowed
applyPatch "$DOS_PATCHES/android_system_bt/337996.patch"; #Q_asb_2022-09 Fix OOB in BNEP_Write
applyPatch "$DOS_PATCHES/android_system_bt/337997.patch"; #Q_asb_2022-09 Fix OOB in reassemble_and_dispatch
fi;

if enterAndClear "system/core"; then
applyPatch "$DOS_PATCHES/android_system_core/332765.patch"; #P_asb_2022-06 Backport of Win-specific suppression of potentially rogue construct that can engage in directory traversal on the host.
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit a6a4ce8e9a6d63014047a447c6bb3ac1fa90b3f4; #Always update recovery
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
#if [ "$DOS_GRAPHENE_MALLOC_BROKEN" = true ]; then applyPatch "$DOS_PATCHES/android_system_core/0002-HM-Increase_vm_mmc.patch"; fi; #(GrapheneOS)
fi;

if enterAndClear "system/nfc"; then
applyPatch "$DOS_PATCHES/android_system_nfc/332767.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #label protected_{fifos,regular} as proc_security (GrapheneOS)
git am "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices (DivestOS)
patch -p1 < "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch" --directory="prebuilts/api/26.0";
fi;

if enterAndClear "system/vold"; then
applyPatch "$DOS_PATCHES/android_system_vold/0001-AES256.patch"; #Add a variable for enabling AES-256 bit encryption (DivestOS)
fi;

if enterAndClear "vendor/nxp/opensource/external/libnfc-nci"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332771.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332458-backport.patch"; #n-asb-2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332459-backport.patch"; #n-asb-2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
fi;

if enterAndClear "vendor/nxp/opensource/packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/328348-backport.patch"; #P_asb_2022-04 Do not set default contactless application without user interaction
fi;

if enterAndClear "vendor/lineage"; then
rm build/target/product/security/lineage.x509.pem; #Remove Lineage keys
rm -rf overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml; #Remove analytics
rm -rf verity_tool; #Resurrect dm-verity
rm -rf overlay/common/frameworks/base/core/res/res/drawable-*/default_wallpaper.png; #Remove Lineage wallpaper
if [ "$DOS_HOSTS_BLOCKING" = true ]; then awk -i inplace '!/50-lineage.sh/' config/common.mk; fi; #Make sure our hosts is always used
awk -i inplace '!/PRODUCT_EXTRA_RECOVERY_KEYS/' config/common.mk; #Remove Lineage extra keys
awk -i inplace '!/security\/lineage/' config/common.mk; #Remove Lineage extra keys
awk -i inplace '!/WeatherProvider/' config/common.mk; #Remove Weather
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml; #Unset default backup provider
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/AudioFX/' config/common.mk; fi; #Remove AudioFX
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi; #Adjust the fused providers
sed -i 's/LINEAGE_BUILDTYPE := UNOFFICIAL/LINEAGE_BUILDTYPE := dos/' config/common.mk; #Change buildtype
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
if [ "$DOS_SILENCE_INCLUDED" = true ]; then sed -i 's/messaging/Silence/' config/telephony.mk; fi; #Replace the Messaging app with Silence
awk -i inplace '!/Eleven/' config/common.mk; #Remove Music Player
awk -i inplace '!/Exchange2/' config/common.mk; #Remove Email
fi;

if enter "vendor/divested"; then
if [ "$DOS_MICROG_INCLUDED" != "NONE" ]; then echo "PRODUCT_PACKAGES += DejaVuNlpBackend IchnaeaNlpBackend NominatimNlpBackend" >> packages.mk; fi; #Include UnifiedNlp backends
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then echo "PRODUCT_PACKAGES += UnifiedNLP" >> packages.mk; fi; #Include UnifiedNlp
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/asus/deb"; then
compressRamdisks;
sed -i 's|vendor/cm|vendor/lineage|' lineage.mk;
awk -i inplace '!/ioctl/' sepolicy/audioserver.te; #neverallow
fi;

if enterAndClear "device/asus/flo"; then
compressRamdisks;
echo "/dev/block/platform/msm_sdcc\.1/by-name/misc u:object_r:misc_block_device:s0" >> sepolicy/file_contexts;
fi;

if enterAndClear "device/asus/msm8916-common"; then
rm -rf Android.bp sensors; #exact duplicate in asus/flo #XXX be careful with this
fi;

if enterAndClear "device/lge/msm8996-common"; then
sed -i '3itypeattribute hwaddrs misc_block_device_exception;' sepolicy/hwaddrs.te;
fi;

#if enterAndClear "device/moto/shamu"; then
#git revert --no-edit 05fb49518049440f90423341ff25d4f75f10bc0c; #restore releasetools #TODO
#fi;

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "vendor" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
if [ "$DOS_DEBLOBBER_REMOVE_IMS" = "false" ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'volteOverride "{}"'; fi;
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableDexPreOpt "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
if [ "$DOS_STRONG_ENCRYPTION_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableStrongEncryption "{}"'; fi;
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio || true;
removeBuildFingerprints || true;

#Tweaks for <2GB RAM devices
enableLowRam "device/asus/fugu";
#Tweaks for <3GB RAM devices
#enableLowRam "device/asus/deb";
#enableLowRam "device/asus/flo";
#enableLowRam "device/htc/flounder";
#enableLowRam "device/htc/flounder_lte";
#enableLowRam "device/lge/bullhead";
#enableLowRam "device/lge/hammerhead";

#Fix broken options enabled by hardenDefconfig()
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/lge/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_STRICT_MEMORY_RWX=y/# CONFIG_STRICT_MEMORY_RWX is not set/" kernel/zte/msm8996/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l*; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
