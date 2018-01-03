#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatchesLinux/0002-Copperhead-Kernel_Hardening/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-3153/ANY/0002.patch
git apply $cvePatchesLinux/CVE-2014-3153/ANY/0004.patch
git apply $cvePatchesLinux/CVE-2016-0774/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-7117/^4.5/0002.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0786/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11059/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11473/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-12153/3.2-^3.16/0001.patch
git apply $cvePatchesLinux/CVE-2017-13080/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-13080-Extra/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-13080-Extra/ANY/0002.patch
git apply $cvePatchesLinux/CVE-2017-13080-Extra/ANY/0003.patch
git apply $cvePatchesLinux/CVE-2017-13080-Extra/ANY/0004.patch
git apply $cvePatchesLinux/CVE-2017-13215/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16535/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16650/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatchesLinux/CVE-2017-6348/^4.9/0001.patch
git apply $cvePatchesLinux/CVE-2017-7533/3.4/0001.patch
git apply $cvePatchesLinux/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
cd $base
