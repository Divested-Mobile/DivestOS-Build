#!/bin/bash
cd $base"kernel/essential/msm8998"
git apply $cvePatchesLinux/0010-Accelerated_AES/3.10+/0016.patch
git apply $cvePatchesLinux/0010-Accelerated_AES/3.10+/0020.patch
git apply $cvePatchesLinux/CVE-2014-9900/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-1583/ANY/0002.patch
git apply $cvePatchesLinux/CVE-2016-6693/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-6696/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-8394/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0610/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0710/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-13218/4.4/0018.patch
git apply $cvePatchesLinux/CVE-2017-13218/4.4/0026.patch
git apply $cvePatchesLinux/CVE-2017-13245/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-14875/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0009.patch
git apply $cvePatchesLinux/CVE-2018-3564/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2018-3597/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2018-5831/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-6693/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-6696/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0750/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-14875/ANY/0001.patch
editKernelLocalversion "-dos.p23"
cd $base