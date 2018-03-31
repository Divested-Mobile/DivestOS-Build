#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2015-2018 Spot Communications, Inc.
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

#Initialize aliases
#source ../../Scripts/LineageOS-11.0/00init.sh

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
mkdir /tmp/ar
cd /tmp/ar
wget https://spotco.us/hosts -N #XXX: /hosts is built from non-commercial use files, switch to /hsc for release

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses"
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$ANDROID_HOME/licenses/android-sdk-license"
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#

#top dir
cp -r $prebuiltApps"Fennec_DOS-Shim" $base"packages/apps/"; #Add a shim to install Fennec DOS without actually including the large APK
cp -r $prebuiltApps"android_vendor_FDroid_PrebuiltApps/." $base"vendor/fdroid_prebuilt/"; #Add the prebuilt apps

enter "packages/apps/Settings"
patch -p1 < $patches"android_packages_apps_Settings/0001-CMStats.patch"; #Remove CMStats

enter "vendor/cm"
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enter "device/zte/nex"
patch -p1 < $patches"android_device_zte_nex/Fixes.patch"
patch -p1 < $patches"android_device_zte_nex/Lower_DPI.patch"
mv cm.mk lineage.mk
sed -i 's/cm_/lineage_/' lineage.mk vendorsetup.sh
#In nex-vendor-blobs.mk
#	"system/lib/libtime_genoff.so" -> "obj/lib/libtime_genoff.so"
#	Remove "WCNSS_qcom_wlan_nv2.bin"

enter "kernel/zte/msm8930"
patch -p1 < $patches"android_kernel_zte_msm8930/MDP-Fix.patch"
patch -p1 < $patches"android_kernel_zte_msm8930/Timeconst-Fix.patch"

#Make changes to all devices
cd $base
find "device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enhanceLocation "$0"' {} \;
find "kernel" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'hardenDefconfig "$0"' {} \;
cd $base
#
#END OF DEVICE CHANGES
#
