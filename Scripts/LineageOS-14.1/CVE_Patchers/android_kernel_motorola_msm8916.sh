#!/bin/bash
cd $base"kernel/motorola/msm8916"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9420/0.patch
git apply $cvePatches/CVE-2014-9781/0.patch
git apply $cvePatches/CVE-2015-1593/0.patch
git apply $cvePatches/CVE-2015-8967/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-3137/0.patch
git apply $cvePatches/CVE-2016-3672/0.patch
git apply $cvePatches/CVE-2016-3865/0.patch
git apply $cvePatches/CVE-2016-3865/1.patch
git apply $cvePatches/CVE-2016-3902/0.patch
git apply $cvePatches/CVE-2016-5858/0.patch
git apply $cvePatches/CVE-2016-5858/1.patch
git apply $cvePatches/CVE-2016-5859/0.patch
git apply $cvePatches/CVE-2016-5867/0.patch
git apply $cvePatches/CVE-2016-6672/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0794/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-6345/0.patch
git apply $cvePatches/CVE-2017-6348/0.patch
cd $base
