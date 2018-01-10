#!/bin/bash
cd $base"kernel/samsung/smdk4412"
git apply $cvePatchesLinux/CVE-2014-1739/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-3153/ANY/0004.patch
git apply $cvePatchesLinux/CVE-2014-4656/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9420/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9781/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9870/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9895/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9900/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2015-6640/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2015-8944/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-2185/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-2186/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-2544/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-3857/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-6753/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-7117/^4.5/0002.patch
git apply $cvePatchesLinux/CVE-2016-8463/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2016-9604/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0403/3.0-^3.18/0001.patch
git apply $cvePatchesLinux/CVE-2017-0404/^3.18/0001.patch
git apply $cvePatchesLinux/CVE-2017-0430/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0648/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0706/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-0786/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-1000380/^4.11/0001.patch
git apply $cvePatchesLinux/CVE-2017-11090/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-11473/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-13215/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-15265/^4.14/0001.patch
git apply $cvePatchesLinux/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatchesLinux/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatchesLinux/CVE-2017-6074/^4.9/0001.patch
git apply $cvePatchesLinux/CVE-2017-6345/^4.9/0001.patch
git apply $cvePatchesLinux/CVE-2017-6348/^4.9/0001.patch
git apply $cvePatchesLinux/CVE-2017-7184/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2017-7184/ANY/0002.patch
git apply $cvePatchesLinux/CVE-2017-7308/ANY/0003.patch
git apply $cvePatchesLinux/CVE-2017-7487/ANY/0001.patch
git apply $cvePatchesLinux/CVE-2014-9781/ANY/0001.patch
editKernelLocalversion "-dos.hp"
cd $base
