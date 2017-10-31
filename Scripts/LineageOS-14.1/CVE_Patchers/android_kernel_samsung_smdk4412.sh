#!/bin/bash
cd $base"kernel/samsung/smdk4412"
git apply $cvePatches/CVE-2014-1739/ANY/0.patch
git apply $cvePatches/CVE-2014-4656/ANY/0.patch
git apply $cvePatches/CVE-2014-9420/ANY/0.patch
git apply $cvePatches/CVE-2014-9781/ANY/0.patch
git apply $cvePatches/CVE-2014-9870/ANY/0.patch
git apply $cvePatches/CVE-2014-9900/ANY/0.patch
git apply $cvePatches/CVE-2015-8944/ANY/0.patch
git apply $cvePatches/CVE-2016-2185/ANY/0.patch
git apply $cvePatches/CVE-2016-2186/ANY/0.patch
git apply $cvePatches/CVE-2016-2544/ANY/0.patch
git apply $cvePatches/CVE-2016-6753/ANY/0.patch
git apply $cvePatches/CVE-2016-9604/ANY/0.patch
git apply $cvePatches/CVE-2017-0403/ANY/0.patch
git apply $cvePatches/CVE-2017-0404/ANY/0.patch
git apply $cvePatches/CVE-2017-0430/ANY/0.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0706/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-10662/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-6074/ANY/0.patch
git apply $cvePatches/CVE-2017-6345/ANY/0.patch
git apply $cvePatches/CVE-2017-6348/ANY/0.patch
git apply $cvePatches/CVE-2017-7487/ANY/0.patch
cd $base
