#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2015-2019 Divested Computing Group
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

#Last verified: 2018-07-10

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
if [ "$DOS_HOSTS_BLOCKING" = true ]; then $DOS_TOR_WRAPPER wget "$DOS_HOSTS_BLOCKING_LIST" -N; fi;
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

#fix prebuilts (disable dexopt and fix suffix)
sed -i 's/LOCAL_DEX_PREOPT := false/LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)/' packages/apps/Fennec_DOS-Shim/Android.mk;
sed -i 's/LOCAL_DEX_PREOPT := false/LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)/' vendor/fdroid_prebuilt/Android.mk;

enterAndClear "build";
sed -i 's/Mms/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence
sed -i '497i$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/base_rules.mk;
sed -i '80iLOCAL_AAPT_FLAGS += --auto-add-overlay' core/package.mk;

enterAndClear "external/bluetooth/bluedroid";
patch -p1 < "$DOS_PATCHES/android_external_bluetooth_bluedroid/251199.patch"; #asb-2019.12-cm11
patch -p1 < "$DOS_PATCHES/android_external_bluetooth_bluedroid/265361.patch"; #asb-2019.12-cm11
patch -p1 < "$DOS_PATCHES/android_external_bluetooth_bluedroid/265493.patch"; #asb-2019.12-cm11
patch -p1 < "$DOS_PATCHES/android_external_bluetooth_bluedroid/265494.patch"; #asb-2019.12-cm11

enterAndClear "external/libnfc-nci";
patch -p1 < "$DOS_PATCHES/android_external_libnfc-nci/258164.patch"; #asb-2019.09-cm11
patch -p1 < "$DOS_PATCHES/android_external_libnfc-nci/258165.patch"; #asb-2019.09-cm11
patch -p1 < "$DOS_PATCHES/android_external_libnfc-nci/264094.patch"; #asb-2019.11-cm11
patch -p1 < "$DOS_PATCHES/android_external_libnfc-nci/264097.patch"; #asb-2019.11-cm11

enterAndClear "external/libvpx";
patch -p1 < "$DOS_PATCHES/android_external_libvpx/253499.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_external_libvpx/253500.patch"; #asb-2019.08-cm11

enterAndClear "external/sfntly";
patch -p1 < "$DOS_PATCHES/android_external_sfntly/251198.patch"; #asb-2019.07-cm11

enterAndClear "external/skia";
patch -p1 < "$DOS_PATCHES/android_external_skia/249705.patch"; #asb-2019.06-cm11

enterAndClear "external/sqlite";
patch -p1 < "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (AndroidHardening-13.0)
patch -p1 < "$DOS_PATCHES/android_external_sqlite/263910.patch"; #asb-2019.11-cm11

enterAndClear "frameworks/av";
patch -p1 < "$DOS_PATCHES/android_frameworks_av/247874.patch"; #asb-2019.06-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/249706.patch"; #asb-2019.07-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/249707.patch"; #asb-2019.07-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/253521.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/253522.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/261040.patch"; #asb-2019.10-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_av/261041.patch"; #asb-2019.10-cm11

enterAndClear "frameworks/base";
hardenLocationFWB "$DOS_BUILD_BASE";
sed -i 's/com.android.mms/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|db_default_journal_mode">PERSIST|db_default_journal_mode">TRUNCATE|' core/res/res/values/config.xml; #Mirror SQLite secure_delete
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0001-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0002-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
patch -p1 < "$DOS_PATCHES/android_frameworks_base/253523.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_base/256318.patch"; #asb-2019.09-cm11
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/264100.patch"; #asb-2019.11-cm11 XXX: breaks things
patch -p1 < "$DOS_PATCHES/android_frameworks_base/265311.patch"; #asb-2019.12-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_base/267438.patch"; #asb-2020.01-cm11
changeDefaultDNS;
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/0008-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries #TODO BACKPORT-11.0

enterAndClear "frameworks/native";
patch -p1 < "$DOS_PATCHES/android_frameworks_native/253524.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_native/256319.patch"; #asb-2019.09-cm11
patch -p1 < "$DOS_PATCHES/android_frameworks_native/256322.patch"; #asb-2019.09-cm11

enterAndClear "packages/apps/Bluetooth";
patch -p1 < "$DOS_PATCHES/android_packages_apps_Bluetooth/264098.patch"; #asb-2019.11-cm11

enterAndClear "packages/apps/Dialer";
rm -rf src/com/android/dialer/cmstats;
patch -p1 < "$DOS_PATCHES/android_packages_apps_Dialer/0001-Remove_Analytics.patch"; #Remove CMStats

enterAndClear "packages/apps/Email";
patch -p1 < "$DOS_PATCHES/android_packages_apps_Email/253862.patch"; #asb-2019.08-cm11
patch -p1 < "$DOS_PATCHES/android_packages_apps_Email/256927.patch"; #asb-2019.09-cm11

enterAndClear "packages/apps/InCallUI";
patch -p1 < "$DOS_PATCHES/android_packages_apps_InCallUI/0001-Remove_Analytics.patch"; #Remove CMStats

enterAndClear "packages/apps/Nfc";
patch -p1 < "$DOS_PATCHES/android_packages_apps_Nfc/261042.patch"; #asb-2019.10-cm11

enterAndClear "packages/apps/Settings";
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options
rm -rf src/com/android/settings/cmstats res/xml/security_settings_cyanogenmod.xml; #Nuke part of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/0001-Remove_Analytics.patch"; #Remove the rest of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/230054.patch"; #ASB disclaimer
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/230392.patch"; #ASB disclaimer translations
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/248015.patch"; #asb-2019.05-cm11

enterAndClear "packages/apps/Trebuchet";
#cp -r "$DOS_PATCHES_COMMON/android_packages_apps_Trebuchet/default_workspace/." "res/xml/"; #TODO BACKPORT-11.0
sed -i 's/mCropView.setTouchEnabled(touchEnabled);/mCropView.setTouchEnabled(true);/' WallpaperPicker/src/com/android/launcher3/WallpaperCropActivity.java;

enterAndClear "packages/apps/UnifiedEmail";
patch -p1 < "$DOS_PATCHES/android_packages_apps_UnifiedEmail/253861.patch"; #asb-2019.08-cm11

enterAndClear "system/core";
sed -i 's/!= 2048/< 2048/' libmincrypt/tools/DumpPublicKey.java; #Allow 4096-bit keys
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
patch -p1 < "$DOS_PATCHES/android_system_core/0001-Harden_Mounts.patch"; #Harden mounts with nodev/noexec/nosuid (AndroidHardening-13.0)

enterAndClear "vendor/cm";
rm -rf terminal;
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
	awk -i inplace '!/DSPManager/' config/common.mk;
fi;
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi;
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/CM_BUILDTYPE := dos/CM_BUILDTYPE := dosNC/' config/common.mk; fi;
sed -i 's/Mms/Silence/' config/telephony.mk; #Replace AOSP Messaging app with Silence
echo 'include vendor/divested/divestos.mk' >> config/common.mk; #Include our customizations

enter "vendor/divested";
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> packages.mk; fi;
if [ "$DOS_HOSTS_BLOCKING" = false ]; then echo "PRODUCT_PACKAGES += $DOS_HOSTS_BLOCKING_APP" >> packages.mk; fi;
awk -i inplace '!/FairEmail/' packages.mk; #FairEmail requires 5.0+
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enterAndClear "device/zte/nex"
mv cm.mk lineage.mk;
sed -i 's/cm_/lineage_/' lineage.mk vendorsetup.sh;
echo "TARGET_DISPLAY_USE_RETIRE_FENCE := true" >> BoardConfig.mk;
sed -i 's/libm libc/libm libc libutils/' charger/Android.mk;
sed -i 's/ro.sf.lcd_density=240/ro.sf.lcd_density=180/' system.prop;
awk -i inplace '!/WCNSS_qcom_wlan_nv_2.bin/' proprietary-files.txt; #Missing
#echo "lib/hw/camera.msm8960.so" >> proprietary-files.txt;
#In nex-vendor-blobs.mk
#	Copy "system/lib/libtime_genoff.so" as "obj/lib/libtime_genoff.so"

enterAndClear "kernel/zte/msm8930"
patch -p1 < "$DOS_PATCHES/android_kernel_zte_msm8930/0001-MDP-Fix.patch";

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -name "gps\.conf" -type f -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationConf "{}"';
find "device" -type d -name "overlay" -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenLocationFWB "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenUserdata "{}"';
find "device" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 8 -I {} bash -c 'hardenBootArgs "{}"';
find "kernel" -maxdepth 2 -mindepth 2 -type d -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'hardenDefconfig "{}"';
cd "$DOS_BUILD_BASE";
deblobAudio;

#Fixes
#Fix broken options enabled by hardenDefconfig()
sed -i "s/# CONFIG_COMPAT_BRK is not set/CONFIG_COMPAT_BRK=y/" kernel/zte/msm8930/arch/arm/configs/msm8960-nex_defconfig;
#
#END OF DEVICE CHANGES
#
