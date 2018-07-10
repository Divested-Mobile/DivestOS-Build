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
if [ "$DOS_HOSTS_BLOCKING" = true ]; then wget "$DOS_HOSTS_BLOCKING_LIST" -N; fi;
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
cp -r "$DOS_PREBUILT_APPS""android_vendor_FDroid_PrebuiltApps/." "$DOS_BUILD_BASE""vendor/fdroid_prebuilt/"; #Add the prebuilt apps

enterAndClear "build";
#patch -p1 < "$DOS_PATCHES/android_build/0001-Automated_Build_Signing.patch"; #Automated build signing (CopperheadOS-13.0) #TODO
#sed -i 's/Mms/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence
sed -i 's/ro.secure=0/ro.secure=1/' core/main.mk;
#sed -i 's/ro.adb.secure=0/ro.adb.secure=1/' core/main.mk;

enterAndClear "external/sqlite";
patch -p1 < "$DOS_PATCHES/android_external_sqlite/0001-Secure_Delete.patch"; #Enable secure_delete by default (CopperheadOS-13.0)

enterAndClear "frameworks/base";
#sed -i 's/com.android.mms/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|db_default_journal_mode">PERSIST|db_default_journal_mode">TRUNCATE|' core/res/res/values/config.xml; #Mirror SQLite secure_delete
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0001-Signature_Spoofing.patch"; fi; #Allow packages to spoof their signature (microG)
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then patch -p1 < "$DOS_PATCHES/android_frameworks_base/0002-Harden_Sig_Spoofing.patch"; fi; #Restrict signature spoofing to system apps signed with the platform key
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/<item>com.android.location.fused<\/item>/a \ \ \ \ \ \ \ \ <item>org.microg.nlp</item>' core/res/res/values/config.xml; fi; #Add UnifiedNLP to location providers
changeDefaultDNS;
#patch -p1 < "$DOS_PATCHES/android_frameworks_base/0008-Disable_Analytics.patch"; #Disable/reduce functionality of various ad/analytics libraries #TODO
rm core/res/res/values/config.xml.orig core/res/res/values/strings.xml.orig;

if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then
enterAndClear "packages/apps/FakeStore";
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/ln -s /ln -sf /' Android.mk;
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;
fi;

enterAndClear "packages/apps/FDroid";
cp "$DOS_PATCHES_COMMON/android_packages_apps_FDroid/default_repos.xml" app/src/main/res/values/default_repos.xml; #Add extra repos
sed -i 's|outputs/apk/|outputs/apk/full/release/|' Android.mk;
sed -i 's|-release-unsigned|-full-release-unsigned|' Android.mk;
sed -i 's|gradle|./gradlew|' Android.mk; #Gradle 4.0 fix
sed -i 's|/$(fdroid_dir) \&\&| \&\&|' Android.mk; #One line wouldn't work... no matter what I tried.
sed -i 's/org\.fdroid\.fdroid/org.fdroid.fdroid_dos/' app/build.gradle; #Change the package ID until https://gitlab.com/fdroid/fdroidclient/issues/843 is implemented

enterAndClear "packages/apps/FDroidPrivilegedExtension";
sed -i 's/43238d512c1e5eb2d6569f4a3afbf5523418b82e0a3ed1552770abb9a9c9ccab/cb1ee2ec40d05ed678f42ae701cdfa29eea79d0e6d633276de230bf3494067c3/' app/src/main/java/org/fdroid/fdroid/privileged/ClientWhitelist.java;
sed -i 's/\"org\.fdroid\.fdroid/\"org.fdroid.fdroid_dos/' app/src/main/java/org/fdroid/fdroid/privileged/ClientWhitelist.java;
#release-key: CB:1E:E2:EC:40:D0:5E:D6:78:F4:2A:E7:01:CD:FA:29:EE:A7:9D:0E:6D:63:32:76:DE:23:0B:F3:49:40:67:C3
#test-key: C8:A2:E9:BC:CF:59:7C:2F:B6:DC:66:BE:E2:93:FC:13:F2:FC:47:EC:77:BC:6B:2B:0D:52:C1:1F:51:19:2A:B8

if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then
enterAndClear "packages/apps/GmsCore";
git submodule update --init --recursive;
fi;

if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then
enterAndClear "packages/apps/GsfProxy";
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;
fi;

enterAndClear "packages/apps/Settings";
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; fi; #microG doesn't support Backup, hide the options
#patch -p1 < "$DOS_PATCHES/android_packages_apps_Settings/0001-CMStats.patch"; #Remove CMStats #TOOD


enterAndClear "packages/apps/Trebuchet";
#cp -r "$DOS_PATCHES_COMMON/android_packages_apps_Trebuchet/default_workspace/." "res/xml/"; #TODO
sed -i 's/mCropView.setTouchEnabled(touchEnabled);/mCropView.setTouchEnabled(true);/' WallpaperPicker/src/com/android/launcher3/WallpaperCropActivity.java;

enterAndClear "system/core";
if [ "$DOS_HOSTS_BLOCKING" = true ]; then cat "$DOS_HOSTS_FILE" >> rootdir/etc/hosts; fi; #Merge in our HOSTS file
patch -p1 < "$DOS_PATCHES/android_system_core/0001-Harden_Mounts.patch"; #Harden mounts with nodev/noexec/nosuid (CopperheadOS-13.0)

enterAndClear "vendor/cm";
rm -rf terminal;
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
#sed -i '3iinclude vendor/cm/config/sce.mk' config/common.mk; #Include extra apps
if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
	awk -i inplace '!/DSPManager/' config/common.mk;
fi;
cp "$DOS_PATCHES_COMMON/android_vendor_divested/sce.mk" config/sce.mk;
if [ "$DOS_MICROG_INCLUDED" = "FULL" ]; then echo "PRODUCT_PACKAGES += GmsCore GsfProxy FakeStore" >> config/sce.mk; fi;
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then echo "PRODUCT_PACKAGES += UnifiedNLP" >> config/sce.mk; fi;
if [ "$DOS_MICROG_INCLUDED" = "NLP" ]; then sed -i '/Google provider/!b;n;s/com.google.android.gms/org.microg.nlp/' overlay/common/frameworks/base/core/res/res/values/config.xml; fi;
if [ "$DOS_MICROG_INCLUDED" != "NONE" ]; then cp "$DOS_PATCHES_COMMON/android_vendor_divested/sce-UnifiedNLP-Backends.mk" config/sce-UnifiedNLP-Backends.mk; fi;
if [ "$DOS_MICROG_INCLUDED" != "NONE" ]; then echo "include vendor/cm/config/sce-UnifiedNLP-Backends.mk" >> config/sce.mk; fi;
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then sed -i 's/CM_BUILDTYPE := dos/CM_BUILDTYPE := dosNC/' config/common.mk; fi;
#sed -i 's/Mms/Silence/' config/telephony.mk; #Replace AOSP Messaging app with Silence
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#

enterAndClear "device/zte/nex"
patch -p1 < "$DOS_PATCHES/android_device_zte_nex/0001-Fixes.patch"; #Build fixes
sed -i 's/ro.sf.lcd_density=240/ro.sf.lcd_density=180/' system.prop;
mv cm.mk lineage.mk;
sed -i 's/cm_/lineage_/' lineage.mk vendorsetup.sh;
awk -i inplace '!/WCNSS_qcom_wlan_nv_2.bin/' proprietary-files.txt;
#In nex-vendor-blobs.mk
#	"system/lib/libtime_genoff.so" -> "obj/lib/libtime_genoff.so"

enterAndClear "kernel/zte/msm8930"
patch -p1 < $patches"android_kernel_zte_msm8930/0001-MDP-Fix.patch";

#Make changes to all devices
cd "$DOS_BUILD_BASE";
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enhanceLocation "$0"' {} \;
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enableForcedEncryption "$0"' {} \;
find "kernel" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenDefconfig "$0"' {} \;
cd "$DOS_BUILD_BASE";

#Fixes
#Fix broken options enabled by hardenDefconfig()
#sed -i "s/CONFIG_DEBUG_RODATA=y/# CONFIG_DEBUG_RODATA is not set/" kernel/google/msm/arch/arm/configs/lineageos_*_defconfig; #Breaks on compile
#
#END OF DEVICE CHANGES
#
