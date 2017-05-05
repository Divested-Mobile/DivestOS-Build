#!/bin/bash

#TODO: Aggressive Doze (Verify Extended Doze First), Failed Unlock Shutdown, Optimized build flags, Optimized toolchain, OTA Updates, Ship Chromium, Wallpaper

#Delete Everything
#repo forall -c 'git add -A && git reset --hard' && rm -rf build external/noto-fonts external/sqlite frameworks/base packages/apps/CMParts packages/apps/FakeStore packages/apps/FDroid packages/apps/FDroidPrivilegedExtension packages/apps/GmsCore packages/apps/GsfProxy packages/apps/IchnaeaNlpBackend packages/apps/SetupWizard system/core vendor/cm out

#Prepare a build
#repo sync -j24 --force-sync && sh ../../Scripts/LAOS-14.1_Patches.sh && source ../../Scripts/Generic_Deblob.sh && source build/envsetup.sh && export ANDROID_HOME="/home/tad/Android/SDK" && export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4096m" && export OTA_PACKAGE_SIGNING_KEY=../../Signing_Keys/releasekey && export SIGNING_KEY_DIR=../../Signing_Keys

#Generate a signed user build
#brunch lineage_clark-user && brunch lineage_bacon-user && brunch lineage_mako-user && brunch lineage_hammerhead-user && brunch lineage_shamu-user && brunch lineage_bullhead-user && brunch lineage_angler-user && brunch lineage_flo-user && brunch lineage_marlin-user

#
#START OF PREPRATION
#
#Set some variables for use later on
base="/home/tad/Android/Build/LineageOS-14.1/"
patches="/home/tad/Android/Patches/LineageOS-14.1/"
ANDROID_HOME="/home/tad/Android/SDK"

#Download some out-of-tree files for use later on
mkdir -p /tmp/ar
cd /tmp/ar
wget https://spotco.us/hosts -N #XXX: Hosts is built from non-commercial use files, switch to /hsc for release
wget https://github.com/Ranks/emojione/raw/master/extras/fonts/emojione-android.ttf -N #XXX: Requires attribuition

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses"
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

enter() {
	dir=$1;
	#project=${$dir//'/'/'_'}; #TODO: Add project conversion, to simplify patching
	cd $base$dir;
	echo "[ENTERING] "$dir;
	git add -A && git reset --hard;
}

enableDexPreOpt() {
	echo "WITH_DEXPREOPT := true" >> BoardConfig.mk
}
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#
enter "build"
#git revert 6f9c2e115aeccd7090f92f1fb91bc6052522cdd1 #Enable dex pre-optimization by default again
patch -p1 < $patches"android_build/0001-Automated_Build_Signing.patch" #Automated build signing

enter "external/noto-fonts"
cp /tmp/ar/emojione-android.ttf other/NotoColorEmoji.ttf #Change emoji font to EmojiOne

enter "system/core"
cat /tmp/ar/hosts >> rootdir/etc/hosts #Merge in our HOSTS file
patch -p1 < $patches"android_system_core/0001-Hardening.patch" #Misc hardening TODO: Fix patch author

enter "external/sqlite"
patch -p1 < $patches"android_external_sqlite/0001-Secure_Delete.patch" #Enable secure_delete by default TODO: Fix patch author

enter "frameworks/opt/net/ims"
patch -p1 < $patches"android_frameworks_opt_net_ims/0001-Fix_Calling.patch" #Fix calling after we remove IMS

enter "packages/apps/FakeStore"
patch -p1 < $patches"android_packages_apps_FakeStore/0001-Fixes.patch" #Update output paths and build tools

enter "packages/apps/IchnaeaNlpBackend"
patch -p1 < $patches"android_packages_apps_IchnaeaNlpBackend/0001-Fixes.patch" #Update output paths and build tools

enter "packages/apps/FDroid"
patch -p1 < $patches"android_packages_apps_FDroid/0001.patch" #Enable privigled module
#patch -p1 < $patches"android_packages_apps_FDroid/0003.patch" #Hide app updates for apps that are installed to /system

enter "packages/apps/FDroidPrivilegedExtension"
patch -p1 < $patches"android_packages_apps_FDroidPrivilegedExtension/0002-Release_Key.patch" #Change to release key
#patch -p1 < $patches"android_packages_apps_FDroidPrivilegedExtension/0003-Test_Keys.patch" #Add test-keys XXX: ONLY USE FOR TEST BUILDS
#release-keys: CB:1E:E2:EC:40:D0:5E:D6:78:F4:2A:E7:01:CD:FA:29:EE:A7:9D:0E:6D:63:32:76:DE:23:0B:F3:49:40:67:C3
#test-keys: C8:A2:E9:BC:CF:59:7C:2F:B6:DC:66:BE:E2:93:FC:13:F2:FC:47:EC:77:BC:6B:2B:0D:52:C1:1F:51:19:2A:B8

enter "vendor/cm"
rm -rf gello #Gello is built out-of-tree and bundles Google Play Services library
patch -p1 < $patches"android_vendor_cm/0001-SCE.patch" #Include our extras such as MicroG and F-Droid
cp $patches"android_vendor_cm/sce.mk" config/sce.mk
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dsc/' config/common.mk;

enter "packages/apps/CMParts"
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml #Nuke part of CMStats
patch -p1 < $patches"android_packages_apps_CMParts/0001-Remove_Analytics.patch" #Remove the rest of CMStats

enter "frameworks/base"
git revert 2aaa0472da8d254da1f07aa65a664012b52410f4 #re-enable doze on devices without gms
patch -p1 < $patches"android_frameworks_base/0003-Signature_Spoofing.patch" #Allow packages to spoof their signature (MicroG) TODO: Fix patch author
patch -p1 < $patches"android_frameworks_base/0005-Harden_Sig_Spoofing.patch" #Restrict signature spoofing to system apps signed with the platform key
rm core/res/res/values/config.xml.orig core/res/res/values/strings.xml.orig core/res/AndroidManifest.xml.orig

enter "device/qcom/sepolicy"
patch -p1 < $patches"android_device_qcom_sepolicy/0001-Camera_Fix.patch" #Fix camera on user builds
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enter "device/motorola/clark"
enableDexPreOpt

enter "kernel/motorola/msm8992"
patch -p1 < $patches"android_kernel_motorola_msm8992/0001-OverUnderClock.patch" #a57: 1.82Ghz -> 2.01Ghz, a53 1.44Ghz -> 1.63Ghz, 384Mhz -> 300Mhz	=+1.14Ghz TODO: Enable by default
patch -p1 < $patches"android_kernel_motorola_msm8992/0002-MMC_Tweak.patch" #Improves MMC performance

enter "device/oneplus/bacon"
enableDexPreOpt

enter "kernel/oneplus/msm8974"
#patch -p1 < $patches"android_kernel_oneplus_msm8974/0001-OverUnderClock.patch" #300Mhz -> 268Mhz, 2.45Ghz -> 2.88Ghz	=+1.72Ghz TODO: Fix patch author
patch -p1 < $patches"android_kernel_oneplus_msm8974/0001-OverUnderClock-EXTREME.patch" #300Mhz -> 268Mhz, 2.45Ghz -> 2.95Ghz	=+2.02Ghz XXX: Not 100% stable under intense workloads

enter "device/lge/mako"
patch -p1 < $patches"android_device_lge_mako/0001-Enable_LTE.patch" #Enable LTE support (Requires LTE hybrid modem to be flashed)

enter "kernel/lge/mako"
patch -p1 < $patches"android_kernel_lge_mako/0001-OverUnderClock.patch" #384Mhz -> 81Mhz, 1.51Ghz -> 1.94Ghz	=+1.72Ghz

enter "kernel/lge/hammerhead"
patch -p1 < $patches"android_kernel_lge_hammerhead/0001-OverUnderClock.patch" #2.26Ghz -> 2.95Ghz	=+2.76Ghz

enter "kernel/moto/shamu"
patch -p1 < $patches"android_kernel_moto_shamu/0001-OverUnderClock.patch" #300Mhz -> 35Mhz, 2.64Ghz -> 2.88Ghz	=+0.96Ghz

enter "kernel/lge/bullhead"
patch -p1 < $patches"android_kernel_lge_bullhead/0001-OverUnderClock.patch" #a57: 1.82Ghz -> 2.01Ghz, a53 1.44Ghz -> 1.63Ghz, 384Mhz -> 300Mhz	=+1.14Ghz TODO: Enable by default
patch -p1 < $patches"android_kernel_lge_bullhead/0002-MMC_Tweak.patch" #Improves MMC performance

enter "kernel/motorola/msm8916"
patch -p1 < $patches"android_kernel_motorola_msm8916/0001-Overclock.patch" #1.36Ghz -> 1.88Ghz	=+ 2.07Ghz
#
#END OF DEVICE CHANGES
#
