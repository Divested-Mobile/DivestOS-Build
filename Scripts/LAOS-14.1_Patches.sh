#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Delete Everything
#repo forall -c 'git add -A && git reset --hard' && rm -rf packages/apps/{FDroid,GmsCore,Silence} out

#Prepare a build
#repo sync -j20 --force-sync && sh ../../Scripts/LAOS-14.1_Patches.sh && source ../../Scripts/LAOS-14.1_Optimize.sh && source ../../Scripts/LAOS-14.1_Rebrand.sh && source ../../Scripts/LAOS-14.1_Theme.sh && source ../../Scripts/Generic_Deblob.sh && source build/envsetup.sh && export ANDROID_HOME="/home/$USER/Android/Sdk" && export ANDROID_JACK_VM_ARGS="-Xmx6144m -Xms512m -Dfile.encoding=UTF-8 -XX:+TieredCompilation" && export JACK_SERVER_VM_ARGUMENTS="${ANDROID_JACK_VM_ARGS}" && GRADLE_OPTS=-Xmx2048m && export KBUILD_BUILD_USER=emy && export KBUILD_BUILD_HOST=dosbm

#Build!
#brunch lineage_mako-user && export OTA_PACKAGE_SIGNING_KEY=../../Signing_Keys/releasekey && export SIGNING_KEY_DIR=../../Signing_Keys && brunch lineage_clark-user && brunch lineage_bacon-user && brunch lineage_thor-userdebug && brunch lineage_angler-user && brunch lineage_bullhead-user && brunch lineage_ether-user && brunch lineage_flounder-user && brunch lineage_flo-user && brunch lineage_FP2-user && brunch lineage_hammerhead-user && brunch lineage_marlin-user && brunch lineage_sailfish-user && brunch lineage_n5110-user && brunch lineage_osprey-user && brunch lineage_shamu-user && brunch lineage_Z00T-user

#Generate an incremental
#./build/tools/releasetools/ota_from_target_files --block -t 8 -i old.zip new.zip update.zip

#
#START OF PREPRATION
#
#Set some variables for use later on
base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"
patches="/mnt/Drive-1/Development/Other/Android_ROMs/Patches/LineageOS-14.1/"
ANDROID_HOME="/home/$USER/Android/Sdk"

#Download some (non-executable) out-of-tree files for use later on
mkdir /tmp/ar
cd /tmp/ar
wget https://spotco.us/hosts -N #XXX: /hosts is built from non-commercial use files, switch to /hsc for release

#Accept all SDK licences, not normally needed but Gradle managed apps fail without it
mkdir -p "$ANDROID_HOME/licenses"
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

enter() {
	echo "================================================================================================"
	dir=$1;
	cd $base$dir;
	echo "[ENTERING] "$dir;
	git add -A && git reset --hard;
}

enableDexPreOpt() {
	echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
	echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
	echo "Enabled dexpreopt";
}

disableDexPreOpt() {
	sed -i 's/WITH_DEXPREOPT := true/WITH_DEXPREOPT := false/' BoardConfig.mk;
	sed -i 's/WITH_DEXPREOPT_PIC := true/WITH_DEXPREOPT_PIC := false/' BoardConfig.mk;
	echo "Disabled dexpreopt";
}

enhanceLocation() {
	cd $base$1;
	#Enable GLONASS
	sed -i 's/#A_GLONASS_POS_PROTOCOL_SELECT/A_GLONASS_POS_PROTOCOL_SELECT/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's/A_GLONASS_POS_PROTOCOL_SELECT = 0.*/A_GLONASS_POS_PROTOCOL_SELECT = 15/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's|A_GLONASS_POS_PROTOCOL_SELECT=0.*</item>|A_GLONASS_POS_PROTOCOL_SELECT=15</item>|' overlay/frameworks/base/core/res/res/values-*/*.xml &>/dev/null || true;
	#Recommended reading: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#XTRA: Only use specified URLs
	sed -i 's|XTRA_SERVER_QUERY=1|XTRA_SERVER_QUERY=0|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's|#XTRA_SERVER|XTRA_SERVER|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Enable HTTPS
	sed -i 's|http://xtra|https://xtra|' overlay/frameworks/base/core/res/res/values-*/*.xml gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Use format version 3 if possible
	if grep -sq "XTRA_VERSION_CHECK" gps.conf gps/gps.conf configs/gps.conf; then #Using hardware/qcom/gps OR precompiled blob OR device specific implementation
		sed -i 's|XTRA_VERSION_CHECK=0|XTRA_VERSION_CHECK=1|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
		sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	elif grep -sq "BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true" BoardConfig.mk boards/*gps.mk; then
		if ! grep -sq "USE_DEVICE_SPECIFIC_LOC_API := true" BoardConfig.mk boards/*gps.mk; then
			if ! grep -sq "libloc" *proprietary*.txt; then #Using hardware/qcom/gps
				sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
			fi;
		fi;
	fi;
	echo "Enhanced location services for $1";
}
export -f enhanceLocation;

enableZram() {
	sed -i 's|#/dev/block/zram0|/dev/block/zram0|' fstab.* rootdir/fstab.* rootdir/etc/fstab.* || true;
	echo "Enabled zram";
}
#
#END OF PREPRATION
#

#
#START OF ROM CHANGES
#
enter "build"
patch -p1 < $patches"android_build/0001-Automated_Build_Signing.patch" #Automated build signing
sed -i 's/messaging/Silence/' target/product/*.mk; #Replace AOSP Messaging app with Silence

enter "device/qcom/sepolicy"
patch -p1 < $patches"android_device_qcom_sepolicy/0001-Camera_Fix.patch" #Fix camera on user builds

enter "external/sqlite"
patch -p1 < $patches"android_external_sqlite/0001-Secure_Delete.patch" #Enable secure_delete by default

enter "frameworks/base"
git revert 0326bb5e41219cf502727c3aa44ebf2daa19a5b3 #re-enable doze on devices without gms
git fetch https://review.lineageos.org/LineageOS/android_frameworks_base refs/changes/75/151975/37 && git cherry-pick FETCH_HEAD #network traffic
sed -i 's/DEFAULT_MAX_FILES = 1000;/DEFAULT_MAX_FILES = 0;/' services/core/java/com/android/server/DropBoxManagerService.java; #Disable DropBox
sed -i '0,/wifi,cell,battery/s/wifi,cell,battery,dnd,flashlight,rotation,bt,airplane/wifi,cell,bt,dnd,flashlight,rotation,battery,profiles,location,airplane,saver,hotspot,nfc/' packages/SystemUI/res/values/config.xml;
sed -i 's/com.android.messaging/org.smssecure.smssecure/' core/res/res/values/config.xml; #Change default SMS app to Silence
sed -i 's|config_longPressOnHomeBehavior">2|config_longPressOnHomeBehavior">0|' core/res/res/values/config.xml;
sed -i 's|config_doubleTapOnHomeBehavior">0|config_doubleTapOnHomeBehavior">8|' core/res/res/values/config.xml;
#sed -i 's|config_permissionReviewRequired">false|config_permissionReviewRequired">true|' core/res/res/values/config.xml; #XXX: Super awesome, but breaks quick tiles
patch -p1 < $patches"android_frameworks_base/0001-Reduced_Resolution.patch" #Allow reducing resolution to save power
patch -p1 < $patches"android_frameworks_base/0002-Keystore.patch" #Fix Keystore
patch -p1 < $patches"android_frameworks_base/0003-Signature_Spoofing.patch" #Allow packages to spoof their signature (MicroG)
patch -p1 < $patches"android_frameworks_base/0005-Harden_Sig_Spoofing.patch" #Restrict signature spoofing to system apps signed with the platform key
rm -rf packages/PrintRecommendationService; #App that just creates popups to install proprietary print apps
rm core/res/res/values/config.xml.orig core/res/res/values/strings.xml.orig

#enter "frameworks/opt/net/ims"
#patch -p1 < $patches"android_frameworks_opt_net_ims/0001-Fix_Calling.patch" #Fix calling after we remove IMS

enter "packages/apps/CMParts"
rm -rf src/org/cyanogenmod/cmparts/cmstats/ res/xml/anonymous_stats.xml res/xml/preview_data.xml #Nuke part of CMStats
git fetch https://review.lineageos.org/LineageOS/android_packages_apps_CMParts refs/changes/15/113415/25 && git cherry-pick FETCH_HEAD #network traffic
sed -i 's|config_showWeatherMenu">true|config_showWeatherMenu">false|' res/values/config.xml; #Disable Weather
patch -p1 < $patches"android_packages_apps_CMParts/0001-Remove_Analytics.patch" #Remove the rest of CMStats
patch -p1 < $patches"android_packages_apps_CMParts/0002-Reduced_Resolution.patch" #Allow reducing resolution to save power

enter "packages/apps/Updater"
patch -p1 < $patches"android_packages_apps_Updater/0001-Server.patch" #Switch to our server

enter "packages/apps/Dialer"
sed -i 's/FLP_DEFAULT = FLP_GOOGLE;/FLP_DEFAULT = FLP_OPENSTREETMAP;/' src/com/android/dialer/lookup/LookupSettings.java; #Change default FLP to OpenStreetMap
sed -i 's/CMSettings.System.ENABLE_FORWARD_LOOKUP, 1)/CMSettings.System.ENABLE_FORWARD_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable FLP by default
sed -i 's/CMSettings.System.ENABLE_PEOPLE_LOOKUP, 1)/CMSettings.System.ENABLE_PEOPLE_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable PLP by default
sed -i 's/CMSettings.System.ENABLE_REVERSE_LOOKUP, 1)/CMSettings.System.ENABLE_REVERSE_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable RLP by default

enter "packages/apps/FakeStore"
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/ln -s /ln -sf /' Android.mk;
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;

enter "packages/apps/FDroid"
patch -p1 < $patches"android_packages_apps_FDroid/0001.patch" #Mark as privigled
patch -p1 < $patches"android_packages_apps_FDroid/0002-Repos.patch" #Add IzzySoft, microG, and Eutopia repos
#sed -i 's|cd $(fdroid_root)/$(fdroid_dir) && gradle assembleRelease|cd $(fdroid_root) && ./gradlew assembleRelease|' Android.mk; #Gradle 4.0 fix #FIXME: Doesn't work?

enter "packages/apps/FDroidPrivilegedExtension"
patch -p1 < $patches"android_packages_apps_FDroidPrivilegedExtension/0002-Release_Key.patch" #Change to release key
#release-keys: CB:1E:E2:EC:40:D0:5E:D6:78:F4:2A:E7:01:CD:FA:29:EE:A7:9D:0E:6D:63:32:76:DE:23:0B:F3:49:40:67:C3
#test-keys: C8:A2:E9:BC:CF:59:7C:2F:B6:DC:66:BE:E2:93:FC:13:F2:FC:47:EC:77:BC:6B:2B:0D:52:C1:1F:51:19:2A:B8

enter "packages/apps/GmsCore"
git submodule update --init --recursive

enter "packages/apps/GsfProxy"
sed -i 's/ext.androidBuildVersionTools = "24.0.3"/ext.androidBuildVersionTools = "25.0.3"/' build.gradle;

enter "packages/apps/IchnaeaNlpBackend"
sed -i 's|$(OUT_DIR)/target/|$(PWD)/$(OUT_DIR)/target/|' Android.mk;
sed -i 's/compileSdkVersion 23/compileSdkVersion 25/' build.gradle;
sed -i 's/buildToolsVersion "23.0.2"/buildToolsVersion "25.0.3"/' build.gradle;

enter "packages/apps/Nfc"
sed -i 's/static final boolean NFC_ON_DEFAULT = true;/static final boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC by default
sed -i 's/static final boolean NDEF_PUSH_ON_DEFAULT = true;/static final boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push by default

enter "packages/apps/offline-calendar"
cp $patches"offline-calendar/Android.mk" Android.mk #Add a build file
sed -i 's/compileSdkVersion 23/compileSdkVersion 25/' Offline-Calendar/build.gradle;
sed -i 's/buildToolsVersion "23.0.3"/buildToolsVersion "25.0.3"/' Offline-Calendar/build.gradle;

enter "packages/apps/Settings"
sed -i 's/Settings.Secure.WEB_ACTION_ENABLED, 1/Settings.Secure.WEB_ACTION_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java; #Disable "Instant Apps"
sed -i 's/private int mPasswordMaxLength = 16;/private int mPasswordMaxLength = 48;/' src/com/android/settings/ChooseLockPassword.java; #Increase max password length
sed -i 's/GSETTINGS_PROVIDER = "com.google.settings";/GSETTINGS_PROVIDER = "com.google.oQuae4av";/' src/com/android/settings/PrivacySettings.java; #MicroG doesn't support Backup, hide the options

enter "packages/apps/SetupWizard"
patch -p1 < $patches"android_packages_apps_SetupWizard/0001-Remove_Analytics.patch" #Remove the rest of CMStats

enter "packages/apps/Silence"
cp $patches"Silence/Android.mk" Android.mk #Add a build file

enter "packages/apps/Trebuchet"
#rm -f res/xml/default_workspace_*.xml #Remove default screens TODO: remove the references in src/com/android/launcher3/InvariantDeviceProfile.java 
sed -i 's|homescreen_search_default">true|homescreen_search_default">false|' res/values/preferences_defaults.xml;
sed -i 's|drawer_compact_default">false|drawer_compact_default">true|' res/values/preferences_defaults.xml;
sed -i 's|use_scroller_default">true|use_scroller_default">false|' res/values/preferences_defaults.xml;
sed -i 's|drawer_search_default">true|drawer_search_default">false|' res/values/preferences_defaults.xml;

enter "packages/inputmethods/LatinIME"
patch -p1 < $patches"android_packages_inputmethods_LatinIME/0001-Voice.patch" #Remove voice input key

enter "packages/services/Telephony"
patch -p1 < $patches"android_packages_services_Telephony/0001-LTE_Only.patch" #LTE only preferred network mode choice #From Copperhead before their LICENSE was added, and its just some constants anyway...

enter "system/core"
cat /tmp/ar/hosts >> rootdir/etc/hosts #Merge in our HOSTS file
patch -p1 < $patches"android_system_core/0001-Harden_Mounts.patch" #Harden mounts with nodev/noexec/nosuid
#patch -p1 < $patches"android_system_core/0002-Harden_Network.patch" #Harden network via sysctls FIXME: Tethering

#enter "system/netd"
#patch -p1 < $patches"android_system_netd/0001-Harden_Network.patch"; #Harden network via iptables FIXME: Tethering

enter "vendor/cm"
rm -rf overlay/common/vendor/cmsdk/packages #Remove analytics
awk -i inplace '!/50-cm.sh/' config/common.mk; #Make sure our hosts is always used
patch -p1 < $patches"android_vendor_cm/0001-SCE.patch" #Include our extras such as MicroG and F-Droid
cp $patches"android_vendor_cm/sce.mk" config/sce.mk
cp $patches"android_vendor_cm/config.xml" overlay/common/vendor/cmsdk/cm/res/res/values/config.xml; #Per app performance profiles
sed -i 's/CM_BUILDTYPE := UNOFFICIAL/CM_BUILDTYPE := dos/' config/common.mk; #Change buildtype
sed -i 's/messaging/Silence/' config/telephony.mk; #Replace AOSP Messaging app with Silence
#sed -i 's/mka bacon/mka bacon target-files-package dist/' build/envsetup.sh; #Create target-files for incrementals

enter "vendor/cmsdk"
git fetch https://review.lineageos.org/LineageOS/cm_platform_sdk refs/changes/21/148321/14 && git cherry-pick FETCH_HEAD #network traffic
awk -i inplace '!/WeatherManagerServiceBroker/' cm/res/res/values/config.xml; #Disable Weather
cp $patches"cm_platform_sdk/profile_default.xml" cm/res/res/xml/profile_default.xml; #Replace default profiles with *way* better ones
sed -i 's/shouldUseOptimizations(weight)/true/' cm/lib/main/java/org/cyanogenmod/platform/internal/PerformanceManagerService.java; #Per app performance profiles fix
#
#END OF ROM CHANGES
#

#
#START OF DEVICE CHANGES
#
enter "device/motorola/clark"
enableDexPreOpt
patch -p1 < $patches"android_device_motorola_clark/0001-Tri_State_Torch.patch" #Tri-state torch

enter "device/oneplus/bacon"
enableDexPreOpt
sed -i "s/TZ.BF.2.0-2.0.0134/TZ.BF.2.0-2.0.0134|TZ.BF.2.0-2.0.0137/" board-info.txt; #Suport new TZ firmware https://review.lineageos.org/#/c/178999/

enter "kernel/oneplus/msm8974"
patch -p1 < $patches"android_kernel_oneplus_msm8974/0001-OverUnderClock-EXTREME.patch" #300Mhz -> 268Mhz, 2.45Ghz -> 2.95Ghz	=+2.02Ghz XXX: Not 100% stable under intense workloads

enter "device/lge/mako"
disableDexPreOpt #bootloops
#patch -p1 < $patches"android_device_lge_mako/0001-Enable_LTE.patch" #Enable LTE support (Requires LTE hybrid modem to be flashed) XXX: Doesn't seem to work under 7.x

enter "kernel/lge/hammerhead"
patch -p1 < $patches"android_kernel_lge_hammerhead/0001-OverUnderClock.patch" #2.26Ghz -> 2.95Ghz	=+2.76Ghz

enter "kernel/motorola/msm8916"
patch -p1 < $patches"android_kernel_motorola_msm8916/0001-Overclock.patch" #1.36Ghz -> 1.88Ghz	=+ 2.07Ghz

#Enhance and improve security of GPS for all devices
find $base"device" -maxdepth 2 -mindepth 2 -type d -exec bash -c 'enhanceLocation "$0"' {} \;
#
#END OF DEVICE CHANGES
#
