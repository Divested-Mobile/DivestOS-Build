#!/bin/bash
cd $base"kernel/oneplus/msm8974"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9781/0.patch
git apply $cvePatches/CVE-2014-9880/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-3672/0.patch
git apply $cvePatches/CVE-2016-6672/0.patch
git apply $cvePatches/CVE-2016-8404/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0751/0.patch
git apply $cvePatches/CVE-2017-0786/0.patch
git apply $cvePatches/CVE-2017-1000365/0.patch
git apply $cvePatches/CVE-2017-11000/0.patch
git apply $cvePatches/CVE-2017-11048/0.patch
git apply $cvePatches/CVE-2017-11059/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-7487/0.patch
git apply $cvePatches/CVE-2017-8247/0.patch
git apply $cvePatches/CVE-2017-9242/0.patch
git apply $cvePatches/CVE-2017-9706/0.patch
git apply $cvePatches/CVE-2017-9725/0.patch
cd $base
