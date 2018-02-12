#!/bin/bash
cd $base"kernel/lge/g3"
git apply $cvePatchesLinux/0002-Copperhead-Kernel_Hardening/ANY/0001.patch
git apply $cvePatchesLinux/0010-Accelerated_AES/3.4/0002.patch
git apply $cvePatchesLinux/CVE-2014-9781/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2015-6640/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-3857/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-3892/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-8404/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-8406/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-9576/3.4/0001.patch
git apply $cvePatchesLinux/CVE-2017-0610/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0611/3.4/0001.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0786/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11090/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11473/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-13215/ANY/0001.patch
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
git apply $cvePatchesLinux/CVE-2017-17558/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-8246/3.4/0002.patch
git apply $cvePatchesLinux/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
editKernelLocalversion "-dos.p30"
cd $base
