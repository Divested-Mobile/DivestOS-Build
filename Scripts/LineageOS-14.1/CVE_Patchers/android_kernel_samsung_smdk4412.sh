#!/bin/bash
cd $base"kernel/samsung/smdk4412"
git apply $cvePatches/CVE-2014-1739/0.patch
git apply $cvePatches/CVE-2014-4656/0.patch
git apply $cvePatches/CVE-2014-7822/0.patch
git apply $cvePatches/CVE-2014-9420/0.patch
git apply $cvePatches/CVE-2014-9781/0.patch
git apply $cvePatches/CVE-2014-9870/0.patch
git apply $cvePatches/CVE-2014-9900/0.patch
git apply $cvePatches/CVE-2015-8944/0.patch
git apply $cvePatches/CVE-2016-0819/0.patch
git apply $cvePatches/CVE-2016-2185/0.patch
git apply $cvePatches/CVE-2016-2186/0.patch
git apply $cvePatches/CVE-2016-2544/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-6753/0.patch
git apply $cvePatches/CVE-2016-9604/0.patch
git apply $cvePatches/CVE-2017-0403/0.patch
git apply $cvePatches/CVE-2017-0404/0.patch
git apply $cvePatches/CVE-2017-0430/0.patch
git apply $cvePatches/CVE-2017-0786/0.patch
git apply $cvePatches/CVE-2017-1000365/0.patch
git apply $cvePatches/CVE-2017-10662/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-2618/0.patch
git apply $cvePatches/CVE-2017-6074/0.patch
git apply $cvePatches/CVE-2017-6345/0.patch
git apply $cvePatches/CVE-2017-6348/0.patch
git apply $cvePatches/CVE-2017-7487/0.patch
cd $base
