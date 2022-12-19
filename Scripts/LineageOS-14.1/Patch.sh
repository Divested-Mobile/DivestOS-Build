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

if enterAndClear "art"; then
applyPatch "$DOS_PATCHES_COMMON/android_art/0001-mmap_fix.patch"; #Workaround for mmap error when building (AOSP)
fi;

if enterAndClear "bionic"; then
applyPatch "$DOS_PATCHES_COMMON/android_bionic/0001-Wildcard_Hosts.patch"; #Support wildcards in cached hosts file (backport from 16.0+) (tdm)
fi;

if enterAndClear "bootable/recovery"; then
git revert --no-edit 3c0d796b79c7a1ee904e0cef7c0f2e20bf84c237; #Remove sideload cache, breaks with large files
applyPatch "$DOS_PATCHES/android_bootable_recovery/0001-Squash_Menus.patch"; #What's a back button? (DivestOS)
sed -i 's/(!has_serial_number || serial_number_matched)/!has_serial_number/' recovery.cpp; #Abort package installs if they are specific to a serial number (GrapheneOS)
fi;

if enterAndClear "build"; then
git revert --no-edit a47d7ee7027ecb50e217c5e4d6ea7e201d7ea033; #Re-enable the downgrade check
applyPatch "$DOS_PATCHES/android_build/0001-OTA_Keys.patch"; #Add correct keys to recovery for OTA verification (DivestOS)
sed -i '50i$(my_res_package): PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/aapt2.mk; #Enable auto-add-overlay for packages, this allows the vendor overlay to easily work across all branches.
sed -i '296iLOCAL_AAPT_FLAGS += --auto-add-overlay' core/package_internal.mk;
awk -i inplace '!/Email/' target/product/core.mk; #Remove Email
awk -i inplace '!/Exchange2/' target/product/core.mk;
sed -i 's/2021-06-05/2022-12-05/' core/version_defaults.mk; #Bump Security String #n-asb-2022-12 #XXX
fi;

if enterAndClear "device/qcom/sepolicy"; then
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy/248649.patch"; #msm_irqbalance: Allow read for stats and interrupts (syphyr)
applyPatch "$DOS_PATCHES/android_device_qcom_sepolicy/0001-Camera_Fix.patch"; #Fix camera on user builds XXX: REMOVE THIS TRASH (DivestOS)
fi;

if enterAndClear "external/chromium-webview"; then
if [ "$(type -t DOS_WEBVIEW_CHERRYPICK)" = "alias" ] ; then DOS_WEBVIEW_CHERRYPICK; fi; #Update the WebView to latest if available
if [ "$DOS_WEBVIEW_LFS" = true ]; then git lfs pull; fi; #Ensure the objects are available
fi;

if enterAndClear "external/expat"; then
applyPatch "$DOS_PATCHES/android_external_expat/337987-backport.patch"; #n-asb-2022-09 Prevent XML_GetBuffer signed integer overflow
applyPatch "$DOS_PATCHES/android_external_expat/337988-backport.patch"; #n-asb-2022-09 Prevent integer overflow in function doProlog
applyPatch "$DOS_PATCHES/android_external_expat/337989-backport.patch"; #n-asb-2022-09 Prevent more integer overflows
fi;

if enterAndClear "external/libavc"; then
applyPatch "$DOS_PATCHES/android_external_libavc/315711.patch"; #n-asb-2021-09 Decoder: Update check for increment u2_cur_slice_num
applyPatch "$DOS_PATCHES/android_external_libavc/323462.patch"; #n-asb-2022-02 Move slice increments after completing header parsing
fi;

if enterAndClear "external/libexif"; then
applyPatch "$DOS_PATCHES/android_external_libexif/323459.patch"; #n-asb-2022-02 Fix MakerNote tag size overflow issues at read time.
applyPatch "$DOS_PATCHES/android_external_libexif/323460.patch"; #n-asb-2022-02 Ensure MakeNote data pointers are initialized with NULL.
applyPatch "$DOS_PATCHES/android_external_libexif/323461.patch"; #n-asb-2022-02 Zero initialize ExifMnoteData<vendor> during construction with exif_mnote_data_<vendor>_new.
fi;

if enterAndClear "external/libnfc-nci"; then
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/317037.patch"; #n-asb-2021-10 Type confusion due to race condition on tag type change
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/318515.patch"; #n-asb-2021-11 OOBW in phNxpNciHal_process_ext_rsp
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/332458.patch"; #n-asb-2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/332459.patch"; #n-asb-2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/332460.patch"; #n-asb-2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/341071.patch"; #n-asb-2022-10 The length of a packet should be non-zero
applyPatch "$DOS_PATCHES/android_external_libnfc-nci/343955.patch"; #n-asb-2022-11 OOBW in phNxpNciHal_write_unlocked()
fi;

if enterAndClear "external/sonivox"; then
applyPatch "$DOS_PATCHES/android_external_sonivox/317038.patch"; #n-asb-2021-10 Fix global buffer overflow in WT_InterpolateNoLoop
fi;

if enterAndClear "external/sqlite"; then
applyPatch "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (AndroidHardening-13.0)
fi;

if enterAndClear "external/tremolo"; then
applyPatch "$DOS_PATCHES/android_external_tremolo/319986.patch"; #n-asb-2021-12 handle cases where order isn't a multiple of dimension
fi;

if enterAndClear "frameworks/av"; then
applyPatch "$DOS_PATCHES/android_frameworks_av/212799.patch"; #FLAC extractor CVE-2017-0592. alt: 212827/174106 (AOSP)
applyPatch "$DOS_PATCHES/android_frameworks_av/319987.patch"; #n-asb-2021-12 Fix heap-buffer-overflow in MPEG4Extractor
applyPatch "$DOS_PATCHES/android_frameworks_av/321222.patch"; #n-asb-2022-01 SimpleDecodingSource:Prevent OOB write in heap mem
fi;

if enterAndClear "frameworks/base"; then
applyPatch "$DOS_PATCHES/android_frameworks_base/315712.patch"; #n-asb-2021-09 Fix race condition between lockNow() and updateLockscreenTimeout
applyPatch "$DOS_PATCHES/android_frameworks_base/315713.patch"; #n-asb-2021-09 Improve ellipsize performance
applyPatch "$DOS_PATCHES/android_frameworks_base/315740.patch"; #n-asb-2021-09 Fix side effects of trace-ipc and dumpheap commands
applyPatch "$DOS_PATCHES/android_frameworks_base/315741.patch"; #n-asb-2021-09 Don't attach private Notification to A11yEvent when user locked
applyPatch "$DOS_PATCHES/android_frameworks_base/317035.patch"; #n-asb-2021-10 Fix a potential thread safety issue in VectorDrawable
applyPatch "$DOS_PATCHES/android_frameworks_base/317036.patch"; #n-asb-2021-10 Apply a maximum char count to the load label api
applyPatch "$DOS_PATCHES/android_frameworks_base/317049.patch"; #n-asb-2021-10 Change ownership of the account request notification.
applyPatch "$DOS_PATCHES/android_frameworks_base/317050.patch"; #n-asb-2021-10 Send targeted broadcasts to prevent other apps from receiving them.
applyPatch "$DOS_PATCHES/android_frameworks_base/318516.patch"; #n-asb-2021-11 camera2: Fix exception swallowing in params classes createFromParcel
applyPatch "$DOS_PATCHES/android_frameworks_base/318517.patch"; #n-asb-2021-11 Bluetooth: Fix formatting in getAlias()
applyPatch "$DOS_PATCHES/android_frameworks_base/319988.patch"; #n-asb-2021-12 Fix serialization bug in GpsNavigationMessage
applyPatch "$DOS_PATCHES/android_frameworks_base/322452.patch"; #n-asb-2022-01 Fix another AddAccountSettings memory leak
applyPatch "$DOS_PATCHES/android_frameworks_base/322453.patch"; #n-asb-2022-01 Force-set a ClipData to prevent later migration.
applyPatch "$DOS_PATCHES/android_frameworks_base/322454.patch"; #n-asb-2022-01 Prevent apps from spamming addAccountExplicitly.
applyPatch "$DOS_PATCHES/android_frameworks_base/331108.patch"; #n-asb-2022-05 Always restart apps if base.apk gets updated.
applyPatch "$DOS_PATCHES/android_frameworks_base/332444.patch"; #n-asb-2022-06 Fixed a concurrent modification crash
applyPatch "$DOS_PATCHES/android_frameworks_base/332445.patch"; #n-asb-2022-06 Fix security hole in GateKeeperResponse
applyPatch "$DOS_PATCHES/android_frameworks_base/332446.patch"; #n-asb-2022-06 Update GeofenceHardwareRequestParcelable to match parcel/unparcel format.
applyPatch "$DOS_PATCHES/android_frameworks_base/332447.patch"; #n-asb-2022-06 Prevent non-admin users from deleting system apps.
applyPatch "$DOS_PATCHES/android_frameworks_base/334325.patch"; #n-asb-2022-06-FIXUP Modify conditions for preventing updated system apps from being downgraded
applyPatch "$DOS_PATCHES/android_frameworks_base/332448.patch"; #n-asb-2022-06 limit TelecomManager#registerPhoneAccount to 10; api doc update
applyPatch "$DOS_PATCHES/android_frameworks_base/332449.patch"; #n-asb-2022-06 Add an OEM configurable limit for zen rules
applyPatch "$DOS_PATCHES/android_frameworks_base/334035.patch"; #n-asb-2022-07 Crash invalid FGS notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/334871.patch"; #n-asb-2022-08 Only allow system and same app to apply relinquishTaskIdentity
applyPatch "$DOS_PATCHES/android_frameworks_base/334872.patch"; #n-asb-2022-08 Stop using invalid URL to prevent unexpected crash
applyPatch "$DOS_PATCHES/android_frameworks_base/334873.patch"; #n-asb-2022-08 Only allow the system server to connect to sync adapters
applyPatch "$DOS_PATCHES/android_frameworks_base/338003.patch"; #n-asb-2022-09 IMMS: Make IMMS PendingIntents immutable
applyPatch "$DOS_PATCHES/android_frameworks_base/343956.patch"; #n-asb-2022-11 Switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_frameworks_base/343957.patch"; #n-asb-2022-11 Check permission for VoiceInteraction
applyPatch "$DOS_PATCHES/android_frameworks_base/344188.patch"; #n-asb-2022-11 Do not send new Intent to non-exported activity when navigateUpTo
applyPatch "$DOS_PATCHES/android_frameworks_base/344189.patch"; #n-asb-2022-11 Move accountname and typeName length check from Account.java to AccountManagerService.
applyPatch "$DOS_PATCHES/android_frameworks_base/344217.patch"; #n-asb-2022-11 Do not dismiss keyguard after SIM PUK unlock
applyPatch "$DOS_PATCHES/android_frameworks_base/345519.patch"; #n-asb-2022-12 Validate package name passed to setApplicationRestrictions.
applyPatch "$DOS_PATCHES/android_frameworks_base/345520.patch"; #n-asb-2022-12 Ignore malformed shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/345521.patch"; #n-asb-2022-12 Fix permanent denial of service via setComponentEnabledSetting
applyPatch "$DOS_PATCHES/android_frameworks_base/345522.patch"; #n-asb-2022-12 Add safety checks on KEY_INTENT mismatch.
git revert --no-edit 0326bb5e41219cf502727c3aa44ebf2daa19a5b3; #Re-enable doze on devices without gms
applyPatch "$DOS_PATCHES/android_frameworks_base/248599.patch"; #Make SET_TIME_ZONE permission match SET_TIME (AOSP)
applyPatch "$DOS_PATCHES/android_frameworks_base/0001-Reduced_Resolution.patch"; #Allow reducing resolution to save power TODO: Add 800x480 (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0001-Browser_No_Location.patch"; #Don't grant location permission to system browsers (GrapheneOS)
applyPatch "$DOS_PATCHES_COMMON/android_frameworks_base/0003-SUPL_No_IMSI.patch"; #Don't send IMSI to SUPL (MSe1969)
if [ "$DOS_SENSORS_PERM" = true ]; then applyPatch "$DOS_PATCHES/android_frameworks_base/0009-Sensors-P1.patch"; fi; #Permission for sensors access (MSe1969)
hardenLocationFWB "$DOS_BUILD_BASE"; #Harden the default GPS config
changeDefaultDNS; #Change the default DNS servers
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox internal logging service
sed -i 's/(notif.needNotify)/(true)/' location/java/com/android/internal/location/GpsNetInitiatedHandler.java; #Notify the user if their location is requested via SUPL
sed -i 's/return 16;/return 64;/' core/java/android/app/admin/DevicePolicyManager.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 72 \* 60 \* 60 \* 1000;/DEFAULT_STRONG_AUTH_TIMEOUT_MS = 12 * 60 * 60 * 1000;/' core/java/android/app/admin/DevicePolicyManager.java; #Decrease the strong auth prompt timeout to occur more often
rm -rf packages/Osu; #Automatic Wi-Fi connection non-sense
rm -rf packages/PrintRecommendationService; #Creates popups to install proprietary print apps
fi;

if enterAndClear "frameworks/minikin"; then
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345523.patch"; #n-asb-2022-12 Fix OOB read for registerLocaleList
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345524.patch"; #n-asb-2022-12 Fix OOB crash for registerLocaleList
fi;

if enterAndClear "frameworks/native"; then
applyPatch "$DOS_PATCHES/android_frameworks_native/315714.patch"; #n-asb-2021-09 Do not modify vector after getting references
applyPatch "$DOS_PATCHES/android_frameworks_native/325993.patch"; #n-asb-2022-03 Check if the window is partially obscured for slippery enters
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

if enterAndClear "hardware/ti/omap4"; then
applyPatch "$DOS_PATCHES/android_hardware_ti_omap4/0001-tuna-camera.patch"; #Fix camera on tuna (repinski)
fi;

if enterAndClear "hardware/ti/wlan"; then
#krack fixes
applyPatch "$DOS_PATCHES/android_hardware_ti_wlan/209209.patch"; #wl12xx: Update SR and MR firmwares versions (Texas Instruments)
applyPatch "$DOS_PATCHES/android_hardware_ti_wlan/209210.patch"; #wl12xx: Update SR PLT firmwares (Texas Instruments)
fi;

if enterAndClear "hardware/qcom/display"; then
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8084.patch" --directory="msm8084"; #(Qualcomm)
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8916.patch" --directory="msm8226";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8960.patch" --directory="msm8960";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8974.patch" --directory="msm8974";
applyPatch "$DOS_PATCHES_COMMON/android_hardware_qcom_display/CVE-2019-2306-msm8994.patch" --directory="msm8994";
#missing msm8909, msm8996, msm8998
applyPatch "$DOS_PATCHES/android_hardware_qcom_display/229952.patch"; #n_asb_09-2018-qcom (AOSP)
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
applyPatch "$DOS_PATCHES/android_hardware_qcom_display/227623.patch"; #n_asb_09-2018-qcom (AOSP)
fi;

if enterAndClear "hardware/qcom/display-caf/msm8998"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_display/227624.patch"; #n_asb_09-2018-qcom (AOSP)
fi;

if enterAndClear "hardware/qcom/gps"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_gps/0001-rollover.patch"; #Fix week rollover (jlask)
fi;

if enterAndClear "hardware/qcom/media"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_media/229950.patch"; #n_asb_09-2018-qcom (AOSP)
applyPatch "$DOS_PATCHES/android_hardware_qcom_media/229951.patch"; #n_asb_09-2018-qcom (AOSP)
fi;

if enterAndClear "hardware/qcom/media-caf/apq8084"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_media/227620.patch"; #n_asb_09-2018-qcom (CAF)
fi;

if enterAndClear "hardware/qcom/media-caf/msm8994"; then
applyPatch "$DOS_PATCHES/android_hardware_qcom_media/227622.patch"; #n_asb_09-2018-qcom (CAF)
fi;

if enterAndClear "packages/apps/Bluetooth"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332451.patch"; #n-asb-2022-06 Removes app access to BluetoothAdapter#setScanMode by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332452.patch"; #n-asb-2022-06 Removes app access to BluetoothAdapter#setDiscoverableTimeout by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/345525.patch"; #n-asb-2022-12 Fix URI check in BluetoothOppUtility.java
fi;

if enterAndClear "packages/apps/Contacts"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/318518.patch"; #n-asb-2021-11 Add permission to start NFC activity to ensure it is from NFC stack
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/319989.patch"; #n-asb-2021-12 Address photo editing security bug
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/332453.patch"; #n-asb-2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES_COMMON/android_packages_apps_Contacts/0004-No_GMaps.patch"; #Use common intent for directions instead of Google Maps URL (GrapheneOS)
fi;

if enterAndClear "packages/apps/CMParts"; then
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml; #Nuke part of CMStats
applyPatch "$DOS_PATCHES/android_packages_apps_CMParts/0001-Remove_Analytics.patch"; #Remove the rest of CMStats (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_CMParts/0002-Reduced_Resolution.patch"; #Allow reducing resolution to save power (DivestOS)
cp -f "$DOS_PATCHES_COMMON/contributors.db" assets/contributors.db; #Update contributors cloud
fi;

if enterAndClear "packages/apps/Dialer"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/332454.patch"; #n-asb-2022-06 No longer export CallSubjectDialog
fi;

if enterAndClear "packages/apps/KeyChain"; then
applyPatch "$DOS_PATCHES/android_packages_apps_KeyChain/319990.patch"; #n-asb-2021-12 Hide overlay on KeyChainActivity
applyPatch "$DOS_PATCHES/android_packages_apps_KeyChain/334036.patch"; #n-asb-2022-07 Encode authority part of uri before showing in UI
fi;

if enterAndClear "packages/apps/Nfc"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/315715.patch"; #n-asb-2021-09 Add HIDE_NON_SYSTEM_OVERLAY_WINDOWS permission to Nfc
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/328308.patch"; #n-asb-2022-04 Do not set default contactless application without user interaction
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/332455.patch"; #n-asb-2022-06 OOB read in phNciNfc_RecvMfResp()
fi;

if enterAndClear "packages/apps/PackageInstaller"; then
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/64d8b44.patch"; #Fix an issue with Permission Review (AOSP/452540)
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/344187.patch"; #n-asb-2022-11 Hide overlays on ReviewPermissionsAtivity
fi;

if enterAndClear "packages/apps/Settings"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/315716.patch"; #n-asb-2021-09 Update string
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/315717.patch"; #n-asb-2021-09 Fix phishing attacks over Bluetooth due to unclear warning message
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/318519.patch"; #n-asb-2021-11 Import translations.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/319991.patch"; #n-asb-2021-12 BluetoothSecurity: Add BLUETOOTH_PRIVILEGED permission for pairing dialog
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/323458.patch"; #n-asb-2022-02 Rephrase dialog message of clear storage dialog for security concern
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/325994.patch"; #n-asb-2022-03 Fix bypass CALL_PRIVILEGED permission in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/327099.patch"; #n-asb-2022-03 Add caller check to com.android.credentials.RESET
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334037.patch"; #n-asb-2022-07 Fix LaunchAnyWhere in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334874.patch"; #n-asb-2022-08 Verify ringtone from ringtone picker is audio
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334875.patch"; #n-asb-2022-08 Fix Settings crash when setting a null ringtone
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345679.patch"; #n-asb-2022-12 Add FLAG_SECURE for ChooseLockPassword and Pattern
git revert --no-edit 2ebe6058c546194a301c1fd22963d6be4adbf961; #Don't hide OEM unlock
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/201113.patch"; #wifi: Add world regulatory domain country code (syphyr)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0001-Captive_Portal_Toggle.patch"; #Add option to disable captive portal checks (MSe1969)
if [ "$DOS_SENSORS_PERM" = true ]; then
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0002-Sensors-P1.patch"; #Permission for sensors access (MSe1969)
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/0002-Sensors-P2.patch";
fi;
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 64;/' src/com/android/settings/ChooseLockPassword.java; #Increase default max password length to 64 (GrapheneOS)
sed -i 's/if (isFullDiskEncrypted()) {/if (false) {/' src/com/android/settings/accessibility/*AccessibilityService*.java; #Never disable secure start-up when enabling an accessibility service
fi;

if enterAndClear "packages/apps/SetupWizard"; then
applyPatch "$DOS_PATCHES/android_packages_apps_SetupWizard/0001-Remove_Analytics.patch"; #Remove the rest of CMStats (DivestOS)
fi;

if enterAndClear "packages/apps/Updater"; then
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0001-Server.patch"; #Switch to our server (DivestOS)
applyPatch "$DOS_PATCHES/android_packages_apps_Updater/0002-Tor_Support.patch"; #Add Tor support (DivestOS)
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
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0001-Voice.patch"; #Remove voice input key (DivestOS)
applyPatch "$DOS_PATCHES_COMMON/android_packages_inputmethods_LatinIME/0002-Disable_Personalization.patch"; #Disable personalization dictionary by default (GrapheneOS)
fi;

if enterAndClear "packages/services/Telecomm"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/332456.patch"; #n-asb-2022-06 limit TelecomManager#registerPhoneAccount to 10
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/343953.patch"; #n-asb-2022-11 Switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/345526.patch"; #n-asb-2022-12 Hide overlay windows when showing phone account enable/disable screen.
fi;

if enterAndClear "packages/services/Telephony"; then
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0001-PREREQ_Handle_All_Modes.patch"; #(DivestOS)
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/0002-More_Preferred_Network_Modes.patch";
fi;

if enterAndClear "packages/providers/ContactsProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_ContactsProvider/334876.patch"; #n-asb-2022-08 enforce stricter CallLogProvider query
fi;

if enterAndClear "packages/providers/MediaProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_MediaProvider/324248.patch"; #n-asb-2022-02 Open all files with O_NOFOLLOW.
fi;

if enterAndClear "packages/providers/TelephonyProvider"; then
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/343954.patch"; #n-asb-2022-11 Check dir path before updating permissions.
fi;

if enterAndClear "system/bt"; then
applyPatch "$DOS_PATCHES/android_system_bt/315718.patch"; #BLE: [IOT] Initiate disconnection when encryption fails during pairing #CVE-2021-1957
applyPatch "$DOS_PATCHES/android_system_bt/315719.patch"; #n-asb-2021-09 SMP: Reject pairing if public_key.x match
applyPatch "$DOS_PATCHES/android_system_bt/320420.patch"; #n-asb-2021-12 osi: Prevent memory allocations with MSB set
applyPatch "$DOS_PATCHES/android_system_bt/323456.patch"; #n-asb-2022-02 security: Use-After-Free in btm_sec_[dis]connected
applyPatch "$DOS_PATCHES/android_system_bt/323457.patch"; #n-asb-2022-02 Reset the IRK after all devices are unpaired
applyPatch "$DOS_PATCHES/android_system_bt/328306.patch"; #n-asb-2022-04 Security fix OOB read due to invalid count in stack/avrc/avrc_pars_ct
applyPatch "$DOS_PATCHES/android_system_bt/334032.patch"; #n-asb-2022-07 Security: Fix out of bound write in HFP client
applyPatch "$DOS_PATCHES/android_system_bt/334033.patch"; #n-asb-2022-07 Check Avrcp packet vendor length before extracting length
applyPatch "$DOS_PATCHES/android_system_bt/334034.patch"; #n-asb-2022-07 Security: Fix out of bound read in AT_SKIP_REST
applyPatch "$DOS_PATCHES/android_system_bt/334877.patch"; #n-asb-2022-08 Removing bonded device when auth fails due to missing keys
applyPatch "$DOS_PATCHES/android_system_bt/337998.patch"; #n-asb-2022-09 Fix OOB in BNEP_Write
applyPatch "$DOS_PATCHES/android_system_bt/337999.patch"; #n-asb-2022-09 Fix OOB in bnep_is_packet_allowed
applyPatch "$DOS_PATCHES/android_system_bt/338000.patch"; #n-asb-2022-09 Fix OOB in reassemble_and_dispatch
applyPatch "$DOS_PATCHES/android_system_bt/341070.patch"; #n-asb-2022-10 Fix potential interger overflow when parsing vendor response
applyPatch "$DOS_PATCHES/android_system_bt/343958.patch"; #n-asb-2022-11 Add buffer in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_system_bt/343959.patch"; #n-asb-2022-11 Add negative length check in process_service_search_rsp
applyPatch "$DOS_PATCHES/android_system_bt/345527.patch"; #n-asb-2022-12 Add length check when copy AVDTP packet
applyPatch "$DOS_PATCHES/android_system_bt/345528.patch"; #n-asb-2022-12 Added max buffer length check
applyPatch "$DOS_PATCHES/android_system_bt/345529.patch"; #n-asb-2022-12 Add missing increment in bnep_api.cc
applyPatch "$DOS_PATCHES/android_system_bt/345530.patch"; #n-asb-2022-12 Add length check when copy AVDT and AVCT packet
applyPatch "$DOS_PATCHES/android_system_bt/345531.patch"; #n-asb-2022-12 Fix integer overflow when parsing avrc response
applyPatch "$DOS_PATCHES/android_system_bt/229574.patch"; #bt-sbc-hd-dualchannel-nougat: Increase maximum Bluetooth SBC codec bitrate for SBC HD (ValdikSS)
applyPatch "$DOS_PATCHES/android_system_bt/229575.patch"; #bt-sbc-hd-dualchannel-nougat: Explicit SBC Dual Channel (SBC HD) support (ValdikSS)
applyPatch "$DOS_PATCHES/android_system_bt/242134.patch"; #avrc_bld_get_attrs_rsp - fix attribute length position off by one (cprhokie)
applyPatch "$DOS_PATCHES/android_system_bt/0001-NO_READENCRKEYSIZE.patch"; #Add an option to let devices opt-out of the HCI_READ_ENCR_KEY_SIZE_SUPPORTED assert (DivestOS)
fi;

if enterAndClear "system/core"; then
applyPatch "$DOS_PATCHES/android_system_core/332457.patch"; #n-asb-2022-06 Backport of Win-specific suppression of potentially rogue construct that can engage
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
git revert --no-edit 0217dddeb5c16903c13ff6c75213619b79ea622b d7aa1231b6a0631f506c0c23816f2cd81645b15f; #Always update recovery XXX: This doesn't seem to work
applyPatch "$DOS_PATCHES/android_system_core/0001-Harden.patch"; #Harden mounts with nodev/noexec/nosuid + misc sysctl changes (GrapheneOS)
sed -i 's/!= 2048/< 2048/' libmincrypt/tools/DumpPublicKey.java; #Allow 4096-bit keys
fi;

if enterAndClear "system/sepolicy"; then
applyPatch "$DOS_PATCHES/android_system_sepolicy/0002-protected_files.patch"; #label protected_{fifos,regular} as proc_security (GrapheneOS)
applyPatch "$DOS_PATCHES/android_system_sepolicy/248600.patch"; #Restrict access to timing information in /proc (AndroidHardening)
applyPatch "$DOS_PATCHES/android_system_sepolicy/0001-LGE_Fixes.patch"; #Fix -user builds for LGE devices (DivestOS)
fi;

if enterAndClear "system/vold"; then
applyPatch "$DOS_PATCHES/android_system_vold/0001-AES256.patch"; #Add a variable for enabling AES-256 bit encryption (DivestOS)
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
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations
cp -f "$DOS_PATCHES_COMMON/apns-conf.xml" prebuilt/common/etc/apns-conf.xml; #Update APN list
awk -i inplace '!/Eleven/' config/common.mk; #Remove Music Player
awk -i inplace '!/Exchange2/' config/common.mk; #Remove Email
fi;

if enterAndClear "vendor/cmsdk"; then
awk -i inplace '!/WeatherManagerServiceBroker/' cm/res/res/values/config.xml; #Disable Weather
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then awk -i inplace '!/CMAudioService/' cm/res/res/values/config.xml; fi; #Remove AudioFX
sed -i 's/shouldUseOptimizations(weight)/true/' cm/lib/main/java/org/cyanogenmod/platform/internal/PerformanceManagerService.java; #Per app performance profiles fix
fi;

if enter "vendor/divested"; then
sed -i 's/TalkBack/TalkBackLegacy/' packages.mk;
awk -i inplace '!/downgrade_after_inactive_days/' build/target/product/lowram.mk; #exceeds length limit
fi;
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
if enterAndClear "device/amazon/hdx-common"; then
echo "TARGET_BLUETOOTH_NO_READENCRKEYSIZE := true" >> BoardConfigCommon.mk; #Fix BT crash
sed -i 's/,encryptable=footer//' rootdir/etc/fstab.qcom; #Using footer will break the bootloader, it might work with /misc enabled
#XXX: If not used with a supported recovery, it'll be thrown into a bootloop, don't worry just 'fastboot erase misc' and reboot
#echo "/dev/block/platform/msm_sdcc.1/by-name/misc /misc emmc defaults defaults" >> rootdir/etc/fstab.qcom; #Add the misc (mmcblk0p5) partition for recovery flags
fi;

if enterAndClear "device/asus/grouper"; then
applyPatch "$DOS_PATCHES/android_device_asus_grouper/0001-Update_Blobs.patch"; #(harryyoud)
applyPatch "$DOS_PATCHES/android_device_asus_grouper/0002-Perf_Tweaks.patch"; #(AndDiSa)
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
echo "recovery_only(\`" >> sepolicy/recovery.te; #304224: Allow recovery to unzip and chmod modem firmware
echo "  allow firmware_file labeledfs:filesystem associate;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:dir rw_dir_perms;" >> sepolicy/recovery.te;
echo "  allow recovery firmware_file:file create_file_perms;" >> sepolicy/recovery.te;
echo "')" >> sepolicy/recovery.te;
fi;

if enterAndClear "device/samsung/exynos5420-common"; then
awk -i inplace '!/shell su/' sepolicy/shell.te; #neverallow
fi;

if enterAndClear "device/samsung/i9100"; then
smallerSystem;
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
awk -i inplace '!/has_powercontrol_widget/' overlay/packages/apps/Settings/res/values/bools.xml; #Fix Settings crash
fi;

if enterAndClear "device/samsung/tuna"; then
#git revert --no-edit e53eea6426da49dfb542929d5aa686667f4d416f; #restore releasetools #TODO
rm setup-makefiles.sh; #broken, deblobber will still function
sed -i 's|vendor/maguro/|vendor/|' libgps-shim/gps.c; #fix dlopen not found
#See: https://review.lineageos.org/q/topic:tuna-sepolicies
applyPatch "$DOS_PATCHES/android_device_samsung_tuna/0001-fix_denial.patch"; #(nailyk)
applyPatch "$DOS_PATCHES/android_device_samsung_tuna/0002-fix_denial.patch";
applyPatch "$DOS_PATCHES/android_device_samsung_tuna/0003-fix_denial.patch";
applyPatch "$DOS_PATCHES/android_device_samsung_tuna/0004-fix_denial.patch";
applyPatch "$DOS_PATCHES/android_device_samsung_tuna/0005-fix_denial.patch"; #(DivestOS)
echo "allow system_server system_file:file execmod;" >> sepolicy/system_server.te; #fix gps load
echo "PRODUCT_PROPERTY_OVERRIDES += persist.sys.force_highendgfx=true" >> device.mk; #override low_ram to fix artifacting
fi;

if enter "vendor/google"; then
echo "" > atv/atv-common.mk;
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
if [ "$DOS_STRONG_ENCRYPTION_ENABLED" = true ]; then find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'enableStrongEncryption "{}"'; fi;
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'updateRegDb "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio || true;
removeBuildFingerprints || true;

#Tweaks for <2GB RAM devices
enableLowRam "device/asus/grouper";
enableLowRam "device/samsung/galaxys2-common";
enableLowRam "device/samsung/i9100";
enableLowRam "device/samsung/i9300";
enableLowRam "device/samsung/maguro";
enableLowRam "device/samsung/manta";
enableLowRam "device/samsung/smdk4412-common";
enableLowRam "device/samsung/toro";
enableLowRam "device/samsung/toroplus";
enableLowRam "device/samsung/tuna";
#Tweaks for <3GB RAM devices
#enableLowRam "device/amazon/apollo";
#enableLowRam "device/amazon/hdx-common";
#enableLowRam "device/amazon/thor";
#enableLowRam "device/htc/m7";
#enableLowRam "device/htc/m7-common";
#enableLowRam "device/htc/msm8960-common";
#enableLowRam "device/samsung/d2att";
#enableLowRam "device/samsung/d2-common";
#enableLowRam "device/samsung/d2spr";
#enableLowRam "device/samsung/d2tmo";
#enableLowRam "device/samsung/d2vzw";
#enableLowRam "device/samsung/i9305";
#enableLowRam "device/samsung/kona-common";
#enableLowRam "device/samsung/msm8960-common";
#enableLowRam "device/samsung/n5100";
#enableLowRam "device/samsung/n5110";
#enableLowRam "device/samsung/n5120";

#Fixes
#Fix broken options enabled by hardenDefconfig()
sed -i "s/# CONFIG_KPROBES is not set/CONFIG_KPROBES=y/" kernel/amazon/hdx-common/arch/arm/configs/*defconfig; #Breaks on compile
sed -i "s/CONFIG_X509_CERTIFICATE_PARSER=y/# CONFIG_X509_CERTIFICATE_PARSER is not set/" kernel/amazon/hdx-common/arch/arm/configs/*defconfig; #Breaks on compile
sed -i "s/CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y/# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set/" kernel/amazon/hdx-common/arch/arm/configs/*defconfig; #Breaks on compile
sed -i "s/CONFIG_SYSTEM_TRUSTED_KEYRING=y/# CONFIG_SYSTEM_TRUSTED_KEYRING is not set/" kernel/amazon/hdx-common/arch/arm/configs/*defconfig; #Breaks on compile
sed -i "s/CONFIG_ASYMMETRIC_KEY_TYPE=y/# CONFIG_ASYMMETRIC_KEY_TYPE is not set/" kernel/amazon/hdx-common/arch/arm/configs/*defconfig; #Breaks on compile
sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/asus/grouper/arch/arm/configs/grouper_defconfig; #Breaks on compile
awk -i inplace '!/STACKPROTECTOR/' kernel/lge/msm8992/arch/arm64/configs/lineageos_*_defconfig; #Breaks on compile
sed -i "s/CONFIG_ARM_SMMU=y/# CONFIG_ARM_SMMU is not set/" kernel/motorola/msm8992/arch/arm64/configs/*defconfig; #Breaks on compile
#tuna fixes
awk -i inplace '!/nfc_enhanced.mk/' device/samsung/toro*/lineage.mk;
awk -i inplace '!/TARGET_RECOVERY_UPDATER_LIBS/' device/samsung/toro*/BoardConfig.mk;
awk -i inplace '!/TARGET_RELEASETOOLS_EXTENSIONS/' device/samsung/toro*/BoardConfig.mk;

sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel/*/*/scripts/dtc/dtc-lexer.l* || true; #Fix builds with GCC 10
rm -v kernel/*/*/drivers/staging/greybus/tools/Android.mk || true;
#
#END OF DEVICE CHANGES
#
echo -e "\e[0;32m[SCRIPT COMPLETE] Primary patching finished\e[0m";
