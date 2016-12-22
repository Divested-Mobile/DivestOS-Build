base="/home/tad/Android/Build/CyanogenMod-13.0/"
patches="/home/tad/Android/Patches-New/"
#
#START OF ROM MODIFICATIONS
#
cd $base"build"
#git add -A && git reset --hard
echo "[ENTERING] build"
echo "[PATCHING] add optional automated signing"
patch -p1 < $patches"Copperhead-13.0/android_build/1.patch" #add optional automated signing
echo "[PATCHING] disable gcc 5.3 optimizations"
patch -p1 < $patches"CyanogenMod-13.0/android_build/Disable_Opt.patch" #disable gcc 5.3 optimizations [ARCHIDROID]
#echo "[PATCHING] enable graphite optimizations"
#patch -p1 < $patches"CyanogenMod-13.0/android_build/Enable_Graphite.patch" #enable graphite optimizations [ARCHIDROID]
echo "[PATCHING] Change toolchain"
patch -p1 < $patches"CyanogenMod-13.0/android_build/Change_Toolchain.patch" #change toolchain
#echo "[PATCHING] Silence"
#patch -p1 < $patches"CyanogenMod-13.0/android_build/silence.patch" #silence

#cd $base"bionic"
#git add -A && git reset --hard
#echo "[ENTERING] bionic"
#echo "[PATCHING] fix gcc 5.3 build failure"
#wget https://github.com/UBERMALLOW/bionic/commit/63465612914cc8ceeedccb76cacdf5eb0a57357b.patch
#patch -p1 < 63465612914cc8ceeedccb76cacdf5eb0a57357b.patch #fix gcc 5.3 build failure

cd $base"frameworks/av"
git add -A && git reset --hard
echo "[ENTERING] frameworks/av"
echo "[PATCHING] fix build failure"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_av/Fix_Build-1.patch" #fix build failure [ARCHIDROID]
#echo "[PATCHING] disable optimization"
#patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_av/Disable_Opt.patch" #disable optimization [ARCHIDROID]

cd $base"system/bt"
git add -A && git reset --hard
echo "[ENTERING] system/bt"
echo "[PATCHING] disable O3 optimizations"
patch -p1 < $patches"CyanogenMod-13.0/android_external_bluetooth_bluedroid/Disable_Opt.patch" #disable O3 optimizations [ARCHIDROID]

cd $base"system/core"
git add -A && git reset --hard
echo "[ENTERING] system/core"
echo "[PATCHING] add back dmesg_restrict"
patch -p1 < $patches"Copperhead-13.0/android_system_core/1.patch" #add back dmesg_restrict
echo "[PATCHING] tighten up mount permissions"
patch -p1 < $patches"Copperhead-13.0/android_system_core/2.patch" #tighten up mount permissions
echo "[PATCHING] tighten up kernel tcp/ip settings"
patch -p1 < $patches"Copperhead-13.0/android_system_core/3.patch" #tighten up kernel tcp/ip settings
echo "[PATCHING] slow down the service respawning rate"
patch -p1 < $patches"Copperhead-13.0/android_system_core/4.patch" #slow down the service respawning rate

cd $base"external/sqlite"
git add -A && git reset --hard
echo "[ENTERING] external/sqlite"
echo "[PATCHING] enable secure_delete by default"
patch -p1 < $patches"Copperhead-13.0/android_external_sqlite/1.patch" #enable secure_delete by default

#cd $base"system/core"
#git add -A && git reset --hard
#echo "[ENTERING] system/core"
#echo "[PATCHING] implement mac randomization"
#patch -p1 < $patches"CyanogenMod-13.0/android_system_core/MAC_Rand.patch" #implement mac randomization

cd $base"packages/apps/Settings"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Settings"
#echo "[PATCHING] implement mac randomization"
#patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_Settings/MAC_Rand.patch" #implement mac randomization
#echo "[PATCHING] implement hostname randomization"
#patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_Settings/Hostname_Rand.patch" #implement hostname randomization
echo "[PATCHING] remove analytics support"
patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_Settings/Remove_Analytics.patch" #remove analytics support
#echo "[PATCHING] DNSCrypt"
#patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_Settings/DNSCrypt.patch" #DNSCrypt
echo "[PATCHING] hide passwords by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Settings/2.patch" #hide passwords by default
#echo "[PATCHING] support setting a separate encryption password"
#patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Settings/3.patch" #support setting a separate encryption password
#echo "[PATCHING] support replacing a separate encryption password"
#patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Settings/4.patch" #support replacing a separate encryption password
#echo "[PATCHING] fix usage of ChooseLockSettingsHelper"
#patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Settings/5.patch" #fix usage of ChooseLockSettingsHelper

cd $base"packages/apps/Nfc"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Nfc"
echo "[PATCHING] disable NFC and NDEF Push by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Nfc/1.patch" #disable NFC and NDEF Push by default

cd $base"frameworks/base"
git add -A && git reset --hard
echo "[ENTERING] frameworks/base"
echo "[PATCHING] hide passwords by default"
patch -p1 < $patches"Copperhead-13.0/android_frameworks_base/1.patch" #hide passwords by default
#echo "[PATCHING] support separate encryption/lockscreen passwords"
#patch -p1 < $patches"Copperhead-13.0/android_frameworks_base/2.patch" #support separate encryption/lockscreen passwords
echo "[PATCHING] remove analytics"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/Remove_Analytics.patch" #remove analytics
echo "[PATCHING] aggressive doze"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/Aggressive_Doze.patch" #aggressive doze
#echo "[PATCHING] DNSCrypt"
#patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/DNSCrypt.patch" #DNSCrypt
echo "[PATCHING] Failed unlock shutdown"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/FailedUnlockShutdown.patch" #Failed Unlock Shutdown
echo "[PATCHING] allow packages to fake their signature"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/SignatureSpoofing2.patch" #allow packages to fake their signature
#echo "[PATCHING] implement hostname randomization"
#patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/Hostname_Rand.patch" #implement hostname randomization
echo "[PATCHING] Change connectivity check URL"
patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/Connectivity.patch"
#patch -p1 < $patches"CyanogenMod-13.0/android_frameworks_base/Radio-1.patch" #Add radio tile
rm frameworks/base/core/res/res/values/config.xml.orig

cd $base"packages/services/Telephony"
git add -A && git reset --hard
echo "[ENTERING] packages/services/Telephony"
git revert 81b568205ba1441ce4e3001bebe5758dc6692ecd #Fix profiles failing to set users preferred network type
echo "[PATCHING] Fix profiles failing to set users preferred network type"
patch -p1 < $patches"CyanogenMod-13.0/android_packages_services_Telephony/PreferredNetworkType_Fix.patch" #Fix profiles failing to set users preferred network type

cd $base"vendor/cm"
git add -A && git reset --hard
echo "[ENTERING] vendor/cm"
git revert ac6115c82ac1365b269607b20b7ade17d7b3ba0f 4b6f22700fbd66b74c3e1941a3d28ef8e99f2a84 1957887a60c971fc708537b953102965c4e59f5a e900dddb9ec5a48cc02f118610360cf1d5b182e8 fdd1ffcc19689a8f1a84862d7c8279fea44ef0e2 df0ba3a0fef911421874257b47cd67b1a9439a0f 0c86291906414a1257c09d0550ae335e44fec17a 30e0b1748ed485912286e83abf798f78f9ab8d01 184bb3de3ea140029cbf88c33717d2eb5b972e7e 08ac10ea1fa489e4c67a487bee569746ded2643e 244e2cda888b9e192027342941f390c0bff76943 d7cbcb3212a20b6dac7026da9285153c0c5822dc e3811ea34886a3c1d99cf5eef67bf39f82156ded b110c513442381270ee340e14e584d61b5b102a7 5c50f84aad906ba7f92d6f1288be8a17bda8516e fd28e9d8193e246802a8357beeaa2230aebee419
echo "[PATCHING] remove analytics support"
patch -p1 < $patches"CyanogenMod-13.0/android_vendor_cm/Remove_Analytics.patch" #remove analytics support
#echo "[PATCHING] DNSCrypt"
#patch -p1 < $patches"CyanogenMod-13.0/android_vendor_cm/DNSCrypt.patch" #DNSCrypt

cd $base"vendor/cmsdk"
git add -A && git reset --hard
echo "[ENTERING] vendor/cmsdk"
echo "[PATCHING] remove analytics support"
git revert 256a7350cef055c58a95c902abdb25c2557097c9
patch -p1 < $patches"CyanogenMod-13.0/cm_platform_sdk/Remove_Analytics.patch" #remove analytics support
#patch -p1 < $patches"CyanogenMod-13.0/cm_platform_sdk/Radio-2.patch" #Add radio tile

cd $base"packages/apps/AudioFX"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/AudioFX"
echo "[PATCHING] remove analytics support"
patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_AudioFX/Remove_Analytics.patch" #remove analytics support
#patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_AudioFX/Fix.patch"
rm -rf res/values-*

cd $base"packages/apps/SetupWizard"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/SetupWizard"
git revert cca206faa1a057cbb75e1648339091d9ea81ff21 1fc92a0531ec50e4b12739dda40b90a505874266 8afa93da6c66860e0860f672fc62f87201fdc887 8331602e949ad95758f126fcac82b64c1249a3c2
echo "[PATCHING] remove analytics support"
patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_SetupWizard/Remove_Analytics.patch" #remove analytics support

cd $base"packages/apps/PhoneCommon"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/PhoneCommon"
git checkout bdac5aa5af2de5aca946f9bc0caf58b5b38935a6 #remove ambientsdk

cd $base"packages/apps/Dialer"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Dialer"
git checkout a245d5701b0452145b2a813464fa2f1fec74fddd #remove ambientsdk

cd $base"packages/apps/InCallUI"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/InCallUI"
git checkout d69ce6c2a65c3d451dfb5837678221e56fef1880 #remove ambientsdk
echo "Fix build"
patch -p1 < $patches"CyanogenMod-13.0/android_packages_apps_InCallUI/Fix_build.patch" #fix build

cd $base"packages/apps/Messaging"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Messaging"
git checkout 0dabdec1f6f6f90b6a0cd45646bdbf5fa79cde74
git revert 0dabdec1f6f6f90b6a0cd45646bdbf5fa79cde74 1f769b00e211fae9f482f063e27efeab39c874ab 1a2c47bc6e3b5512544acf8146b76d6a9847195d 4bd35b2f0ec3dff9fd76a76a0cb473da8e63951f dd899f11158bc65a7e3220d119d48cbea5e38bc9 4052475dd64ecd5445c2f60edb6b644e47315a79 49f0c076af4dd487014eb54525a3a93d1ad378da 252ac72f1007c7742392eb34c6e2278321674898 #remove ambientsdk

cd $base"packages/apps/Contacts"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Contacts"
git checkout 1e2ad0157e708d06728ef575aa556c1e0455d278 #remove ambientsdk

cd $base"packages/apps/ContactsCommon"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/ContactsCommon"
git checkout 463be6a1088c8a3259d618ac67884a74ae8c2d8a #remove ambientsdk

cd $base"packages/providers/ContactsProvider"
git add -A && git reset --hard
echo "[ENTERING] packages/providers/ContactsProvider"
git checkout edec4c11c704e9908f1d4f915a4ec2e0eefe54fe #remove ambientsdk

cd $base"packages/apps/Trebuchet"
git add -A && git reset --hard
git revert abc57d4d5d7f408b26859de2eda60d39cc474c3d 24904352007174ab1555fd201982482c797cfb9f 6fa6ff6929948a1b522f93aac2af226555a98e3e 90106d85b75a60a8bdc9c4ad891e4a2e7ce548dd #remove ambientsdk
#patch -p1 < $patches"CyanogenMod-13.0/ndroid_packages_apps_Trebuchet/Remove_Analytics.patch" #remove analytics support
#git revert 90106d85b75a60a8bdc9c4ad891e4a2e7ce548dd d20f7796e45dcae0e619d3bb76a3a89674705702 097b9503f45ae2a50c501fa95d13776d656621bb 27f915deda69206c7707fb8139c73de442cd5c1c 01b60e8bff4251f5bc850481d83c2ebe86f22b8a aa3fa6f64368c8855ae3cc167c966ffce74c2db8 adcd3cc2f909145ce54458bcd0505249ba22ef10 3bf013a1eb2764fb3c12dc55739cf3c78fd3c20c 3722477e3550364b94b22083f6a3b3ec3c515398 0c71feed0b3156b25785d735ec0bf6ce0351e965 7a6af0078166d470d98fd28c11b7d32c7e98d936 4467b51a476a2fc452e90f2b48317c0963f229a4 b68836f388cb6ac06ba813f762899a2c900e2c3c 7df0227f6a835641a3d41327a65845806ef070fb a20b046db71039ee581bb80274cf1fc450b3fd99

cd $base"packages/apps/Camera2"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Camera2"
echo "[PATCHING] disable location recording by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Camera2/1.patch" #disable location recording by default

cd $base"packages/apps/Browser"
git add -A && git reset --hard
echo "[ENTERING] packages/apps/Browser"
echo "[PATCHING] remove duckduckgo referral strings"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/1.patch" #remove duckduckgo referral strings
echo "[PATCHING] switch default search engine to duckduckgo"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/2.patch" #switch default search engine to duckduckgo
echo "[PATCHING] switch default home page to duckduckgo"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/3.patch" #switch default home page to duckduckgo
echo "[PATCHING] disable link preloading by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/4.patch" #disable link preloading by default
echo "[PATCHING] disable search result preloading by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/5.patch" #disable search result preloading by default
echo "[PATCHING] disable plugins by default"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/6.patch" #disable plugins by default
echo "[PATCHING] remove RLZ tracking"
patch -p1 < $patches"Copperhead-13.0/android_packages_apps_Browser/7.patch" #remove RLZ tracking

cd $base"device/lge/hammerhead"
git add -A && git reset --hard
git revert e939348644bff685bf8821e95f2221043d41764c

cd $base"vendor/oneplus"
git add -A && git reset --hard
git checkout 7bcbecccd50479086fabec8e8cef34e98e03be31
cd $base"device/oneplus/bacon"
git add -A && git reset --hard
#echo "UPDATING ONEPLUS VENDOR FILES"
#./setup-makefiles.sh

#
#END OF ROM MODIFICATIONS
#
