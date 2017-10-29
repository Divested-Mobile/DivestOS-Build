#!/bin/bash
cd $base"kernel/lge/hammerhead"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9881/0.patch
git apply $cvePatches/CVE-2015-1593/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-5829/0.patch
git apply $cvePatches/CVE-2016-8650/0.patch
git apply $cvePatches/CVE-2016-9604/0.patch
git apply $cvePatches/CVE-2017-0611/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0751/0.patch
git apply $cvePatches/CVE-2017-0786/0.patch
git apply $cvePatches/CVE-2017-1000365/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-2618/0.patch
git apply $cvePatches/CVE-2017-2671/0.patch
git apply $cvePatches/CVE-2017-5970/0.patch
git apply $cvePatches/CVE-2017-6074/0.patch
git apply $cvePatches/CVE-2017-6345/0.patch
git apply $cvePatches/CVE-2017-6348/0.patch
git apply $cvePatches/CVE-2017-6951/0.patch
git apply $cvePatches/CVE-2017-7487/0.patch
git apply $cvePatches/CVE-2017-8247/0.patch
git apply $cvePatches/CVE-2017-9242/0.patch
cd $base
