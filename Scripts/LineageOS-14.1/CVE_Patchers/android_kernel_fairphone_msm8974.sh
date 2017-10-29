#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-3672/0.patch
git apply $cvePatches/CVE-2017-0430/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0786/0.patch
git apply $cvePatches/CVE-2017-11059/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-6348/0.patch
cd $base
