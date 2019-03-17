#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2015-2018 Divested Computing, Inc.
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

#Generate an incremental
#./build/tools/releasetools/ota_from_target_files --block -t 8 -i old.zip new.zip update.zip

#Generate firmware deblobber
#mka firmware_deblobber

#
#START OF PREPRATION
#
#Download some (non-executable) out-of-tree files for use later on
cd "$DOS_TMP_DIR";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then $DOS_TOR_WRAPPER wget "$DOS_HOSTS_BLOCKING_LIST" -N; fi;
cd "$DOS_BUILD_BASE";

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses";
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$ANDROID_HOME/licenses/android-sdk-license";
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license";
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
#patch -p1 < "$DOS_PATCHES/android_build/0001-Automated_Build_Signing.patch"; #Automated build signing (CopperheadOS-13.0) #TODO BACKPORT-11.0
sed -i 's/Mms/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence
sed -i '497i$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_AAPT_FLAGS += --auto-add-overlay' core/base_rules.mk;
sed -i '80iLOCAL_AAPT_FLAGS += --auto-add-overlay' core/package.mk;

enterAndClear "external/sqlite";
patch -p1 < "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (CopperheadOS-13.0)

enterAndClear "frameworks/base";
hardenLocationFWB "$DOS_BUILD_BASE";
sed -i 's/com.android.mms/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|db_default_journal_mode">PERSIST|db_default_journal_mode">TRUNCATE|' core/res/res/values/config.xml; #Mirror SQLite secure_delete
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0001-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0002-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
changeDefaultDNS;
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/0008-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries #TODO BACKPORT-11.0

enterAndClear "packages/apps/Dialer";
rm -rf src/com/android/dialer/cmstats;
patch -p1 < "$DOS_PATCHES/android_packages_apps_Dialer/0001-Remove_Analytics.patch"; #Remove CMStats

enterAndClear "packages/apps/InCallUI";
patch -p1 < "$DOS_PATCHES/android_packages_apps_InCallUI/0001-Remove_Analytics.patch"; #Remove CMStats

enterAndClear "packages/apps/Settings";
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options
rm -rf src/com/android/settings/cmstats res/xml/security_settings_cyanogenmod.xml; #Nuke part of CMStats
patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/0001-Remove_Analytics.patch"; #Remove the rest of CMStats


enterAndClear "packages/apps/Trebuchet";
#cp -r "$DOS_PATCHES_COMMON/android_packages_apps_Trebuchet/default_workspace/." "res/xml/"; #TODO BACKPORT-11.0
sed -i 's/mCropView.setTouchEnabled(touchEnabled);/mCropView.setTouchEnabled(true);/' WallpaperPicker/src/com/android/launcher3/WallpaperCropActivity.java;

enterAndClear "system/core";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
patch -p1 < "$DOS_PATCHES/android_system_core/0001-Harden_Mounts.patch"; #Harden mounts with nodev/noexec/nosuid (CopperheadOS-13.0)

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
echo "lib/hw/camera.msm8960.so" >> proprietary-files.txt;
#In nex-vendor-blobs.mk
#	Copy "system/lib/libtime_genoff.so" as "obj/lib/libtime_genoff.so"

enterAndClear "kernel/zte/msm8930"
patch -p1 < "$DOS_PATCHES/android_kernel_zte_msm8930/0001-MDP-Fix.patch";

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "hardware/qcom/gps" -name "gps\.conf" -type f -exec bash -c 'hardenLocationConf "$0"' {} \;;
find "device" -name "gps\.conf" -type f -exec bash -c 'hardenLocationConf "$0"' {} \;;
find "device" -type d -name "overlay" -exec bash -c 'hardenLocationFWB "$0"' {} \;;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenUserdata "$0"' {} \;;
find "kernel" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenDefconfig "$0"' {} \;;
cd "$DOS_BUILD_BASE";

#Fixes
#Fix broken options enabled by hardenDefconfig()
#sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig;
sed -i "s/# CONFIG_COMPAT_BRK is not set/CONFIG_COMPAT_BRK=y/" kernel/zte/msm8930/arch/arm/configs/msm8960-nex_defconfig;
#
#END OF DEVICE CHANGES
#
