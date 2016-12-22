base="/mnt/Drive-1/Development/Android_ROMs/Build/Copperhead-12.1/"
patches="/home/spotcomms/Development/Android_ROMs/Patches/"

cd $base"vendor/cm"
git add -A && git reset --hard
git revert 052a36a5898bd8a4f37008c1df72841c5d9d69f0
git revert d0e72eba2773a42049fb76b4306718dd2cb3a7fd
patch -p1 < $patches"Per-App-Performance-Profiles.patch"

cd $base"build"
git add -A && git reset --hard
git revert f52293aca0055be5bd4b206f5c371a86767b38e5
git revert b00b395580ac951c1f1c8a443b477138ce2cb647
wget https://github.com/ArchiDroid/android_build/commit/f9b983e8e11624b48ae575da206f1baf6979772c.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1
patch -p1 < f9b983e8e11624b48ae575da206f1baf6979772c.patch
patch -p1 < $patches"Change_Toolchain.patch"

#cd $base"kernel/oneplus/msm8974"
#git add -A && git reset --hard
#wget https://github.com/copperhead/android_kernel_lge_hammerhead/commit/488a56d31d16b11a11bae18b768cf567821c3a3b.patch #MAC Address Randomization
#patch -p1 < 488a56d31d16b11a11bae18b768cf567821c3a3b.patch
#patch -p1 < $patches"Defconfig_Hardening.patch"
#rm *.patch

cd $base"device/oneplus/bacon"
git add -A && git reset --hard
patch -p1 < $patches"SEPolicy-Fixes-1.patch"
patch -p1 < $patches"SEPolicy-Fixes-3.patch"

cd $base"device/qcom/sepolicy"
git add -A && git reset --hard
patch -p1 < $patches"SEPolicy-Fixes-2.patch"

cd $base"external/bluetooth/bluedroid"
git add -A && git reset --hard
wget https://github.com/ArchiDroid/android_external_bluetooth_bluedroid/commit/932c01b05465fbf1ae3933efa915902b7f30aec9.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 932c01b05465fbf1ae3933efa915902b7f30aec9.patch
rm *.patch

cd $base"libcore"
git add -A && git reset --hard
wget https://github.com/ArchiDroid/android_libcore/commit/73098e8a00487b055a569760a43fd6fde342d703.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 73098e8a00487b055a569760a43fd6fde342d703.patch
rm *.patch

cd $base"frameworks/av"
git add -A && git reset --hard
wget https://github.com/ArchiDroid/android_frameworks_av/commit/038d57b7b713edb1016d5dcc977459701949e487.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 038d57b7b713edb1016d5dcc977459701949e487.patch
rm *.patch

cd $base"packages/apps/Browser"
git add -A && git reset --hard
wget https://github.com/CyanogenMod/android_packages_apps_Browser/commit/3b243843b6d31ccbe490befbc92e457b28a092c9.patch #Browser UI Update http://review.cyanogenmod.org/#/c/93232/
git apply --binary --verbose --allow-binary-replacement 3b243843b6d31ccbe490befbc92e457b28a092c9.patch
rm *.patch

cd $base"frameworks/base"
git add -A && git reset --hard
patch -p1 < $patches"Battery-Power-Saver-Tweak.patch"
