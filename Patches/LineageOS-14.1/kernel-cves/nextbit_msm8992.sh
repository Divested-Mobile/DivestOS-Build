#Created using raymanfx's android-cve-checker
kernelPath="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/kernel/nextbit/msm8992";
cvePatch="/home/spotcomms/Development/Other/Android_ROMs/Repos/android-cve-checker/patches/3.10/";
git -C $kernelPath apply --3way $cvePatch"CVE-2014-3601.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2014-9903.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2014-9922.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2015-8019.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2015-8961.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-10153.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-10290.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-3843.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-6791.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-7097.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2016-9576.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2017-2618.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2017-2647.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2017-7308.patch"
git -C $kernelPath apply --3way $cvePatch"CVE-2017-8890.patch"
