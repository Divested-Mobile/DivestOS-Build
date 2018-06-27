#!/bin/bash
cd $base"kernel/lge/mako"
git apply $cvePatchesLinux/0010-Accelerated_AES/3.4/0002.patch
git apply $cvePatchesLinux/0012-Copperhead-Deny_USB/3.4/3.4-Backport.patch
git apply $cvePatchesLinux/CVE-2013-4738/ANY/0002.patch
git apply $cvePatchesLinux/CVE-2016-3857/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-3894/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-9793/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-1000111/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11473/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16535/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16650/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatchesLinux/CVE-2017-17806/ANY/0001.patch
git apply $cvePatchesLinux/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
editKernelLocalversion "-dos.p19"
cd $base
