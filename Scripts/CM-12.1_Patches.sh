base="/mnt/Drive-1/Development/Android_ROMs/Build/CyanogenMod-12.1/"
patches="/home/spotcomms/Development/Android_ROMs/Patches/"

cd $base"packages/apps/Settings"
git reset --hard
git revert 50fed8b6fff37086902f5f3fc4caf51261757ed7
wget https://github.com/copperhead/android_packages_apps_Settings/commit/2a28513c49552d6bef8249be47c0f293f80dd2a2.patch #Remove analytics
patch -p1 < 2a28513c49552d6bef8249be47c0f293f80dd2a2.patch
wget https://github.com/copperhead/android_packages_apps_Settings/commit/79e4e84e3beb4f0fb4c1b41a6b16cd23d1908319.patch #Implement setting a seperate encryption password [2/4] http://review.cyanogenmod.org/#/c/109208/
patch -p1 < 79e4e84e3beb4f0fb4c1b41a6b16cd23d1908319.patch
wget https://github.com/copperhead/android_packages_apps_Settings/commit/8468988b59320d40c351b42195e8a783b5fdd710.patch #Implement setting a seperate encryption password [3/4] http://review.cyanogenmod.org/#/c/109209/
patch -p1 < 8468988b59320d40c351b42195e8a783b5fdd710.patch
wget https://github.com/copperhead/android_packages_apps_Settings/commit/70b97620ec19331ef99ea8207549dba432571074.patch #Implement setting a seperate encryption password [4/4] http://review.cyanogenmod.org/#/c/109210/
patch -p1 < 70b97620ec19331ef99ea8207549dba432571074.patch
wget https://github.com/copperhead/android_packages_apps_Settings/commit/939d0c93ff21c6a7ac7fe4a3eb386ee98950f1f9.patch #Hide sensitive notifiation content by default
patch -p1 < 939d0c93ff21c6a7ac7fe4a3eb386ee98950f1f9.patch
rm *.patch

cd $base"build"
git reset --hard
wget https://github.com/ArchiDroid/android_build/commit/f9b983e8e11624b48ae575da206f1baf6979772c.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1
patch -p1 < f9b983e8e11624b48ae575da206f1baf6979772c.patch
patch -p1 < $patches"Change_Toolchain.patch"
rm *.patch

cd $base"external/bluetooth/bluedroid"
git reset --hard
wget https://github.com/ArchiDroid/android_external_bluetooth_bluedroid/commit/932c01b05465fbf1ae3933efa915902b7f30aec9.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 932c01b05465fbf1ae3933efa915902b7f30aec9.patch
rm *.patch

cd $base"libcore"
git reset --hard
wget https://github.com/ArchiDroid/android_libcore/commit/73098e8a00487b055a569760a43fd6fde342d703.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 73098e8a00487b055a569760a43fd6fde342d703.patch
rm *.patch

cd $base"frameworks/av"
git reset --hard
wget https://github.com/ArchiDroid/android_frameworks_av/commit/038d57b7b713edb1016d5dcc977459701949e487.patch #JustArchi's ArchiDroid Compiler Flag Optimizations V4.1 Fix
patch -p1 < 038d57b7b713edb1016d5dcc977459701949e487.patch
rm *.patch

cd $base"frameworks/base"
git reset --hard
wget https://github.com/copperhead/android_frameworks_base/commit/7dee7f276ab85af15d26e662199dec9c7f91f4c2.patch #Remove analytics
patch -p1 < 7dee7f276ab85af15d26e662199dec9c7f91f4c2.patch
wget https://github.com/copperhead/android_frameworks_base/commit/3942bcc948594403e1df3849c5753eb550f5ce7e.patch #Implement setting a seperate encryption password [1/4] http://review.cyanogenmod.org/#/c/109207/
patch -p1 < 3942bcc948594403e1df3849c5753eb550f5ce7e.patch
patch -p1 < $patches"Battery-Power-Saver-Tweak.patch"
rm *.patch

cd $base"vendor/cm"
git reset --hard
wget https://github.com/copperhead/android_vendor_cm/commit/40efb1195a899881fef5effa1d445f1343a28305.patch #Remove analytics
patch -p1 < 40efb1195a899881fef5effa1d445f1343a28305.patch
patch -p1 < $patches"Per-App-Performance-Profiles.patch"
rm *.patch

cd $base"vendor/cmsdk"
git reset --hard
git revert 0c0aef6666490e6ec7055dc87503a63edbf66c98
wget https://github.com/copperhead/cm_platform_sdk/commit/561f4572a2dc74a2d8575b13549cebe8b4b3fdf8.patch #Remove analytics
patch -p1 < 561f4572a2dc74a2d8575b13549cebe8b4b3fdf8.patch
rm *.patch

cd $base"packages/apps/SetupWizard"
git reset --hard
wget https://github.com/copperhead/android_packages_apps_SetupWizard/commit/0b105608a427514100b3276df37443702c313385.patch #Remove analytics
patch -p1 < 0b105608a427514100b3276df37443702c313385.patch
rm *.patch

cd $base"packages/apps/Trebuchet"
git reset --hard
wget https://github.com/copperhead/android_packages_apps_Trebuchet/commit/132a07a365c5b25d3fdda557b57d33cfe5329c62.patch #Remove analytics
patch -p1 < 132a07a365c5b25d3fdda557b57d33cfe5329c62.patch
rm *.patch

cd $base"packages/apps/Browser"
git reset --hard
wget https://github.com/copperhead/android_packages_apps_Browser/commit/d78c4629b2843d3cea7b627611e16f9cbb2f519c.patch #Delete DuckDuckGo referral
patch -p1 < d78c4629b2843d3cea7b627611e16f9cbb2f519c.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/4095550928383375f6434e80ce114ba4b6c56cae.patch #Change default search engine to DuckDuckGo
patch -p1 < 4095550928383375f6434e80ce114ba4b6c56cae.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/5040a83f034dfd3aa611b8b1d06f7eb36caf4c85.patch #Change default home page to DuckDuckGo
patch -p1 < 5040a83f034dfd3aa611b8b1d06f7eb36caf4c85.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/c310d10d80d3ee5023f67e64d13a9ac36f4eb560.patch #Disable link preloading by default
patch -p1 < c310d10d80d3ee5023f67e64d13a9ac36f4eb560.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/9e0375241021014472602dff9baf45fb2d6be178.patch #Disable search result preloading by default
patch -p1 < 9e0375241021014472602dff9baf45fb2d6be178.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/6b67ab10f1dc6d9cc572e0ff9404a1944c7b759c.patch #Disable plugins by default
patch -p1 < 6b67ab10f1dc6d9cc572e0ff9404a1944c7b759c.patch
wget https://github.com/copperhead/android_packages_apps_Browser/commit/807d9857cee9154b8039b61a7bb4d08fbe80fcf3.patch #Remove RLZ tracking
patch -p1 < 807d9857cee9154b8039b61a7bb4d08fbe80fcf3.patch
wget https://github.com/CyanogenMod/android_packages_apps_Browser/commit/3b243843b6d31ccbe490befbc92e457b28a092c9.patch #Browser UI Update http://review.cyanogenmod.org/#/c/93232/
git apply --binary --verbose --allow-binary-replacement 3b243843b6d31ccbe490befbc92e457b28a092c9.patch
rm *.patch
