#!/bin/bash
cd $base"kernel/lge/msm8974"
git apply $cvePatchesLinux/0002-Copperhead-Kernel_Hardening/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2015-8939/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-0806/prima/0001.patch
git apply $cvePatchesLinux/CVE-2016-0806/prima/0006.patch
git apply $cvePatchesLinux/CVE-2016-0806/prima/0007.patch
git apply $cvePatchesLinux/CVE-2016-0806/prima/0010.patch
git apply $cvePatchesLinux/CVE-2016-6751/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0648/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11473/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16525/^4.13/0002.patch
git apply $cvePatchesLinux/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16535/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16650/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatchesLinux/CVE-2017-7487/ANY/0001.patch
git apply $cvePatchesLinux/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
editKernelLocalversion "-dos.p23"
cd $base
