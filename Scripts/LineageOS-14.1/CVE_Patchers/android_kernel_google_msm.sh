#!/bin/bash
cd $base"kernel/google/msm"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9781/0.patch
git apply $cvePatches/CVE-2015-1593/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-3859/0.patch
git apply $cvePatches/CVE-2016-8404/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0751/0.patch
git apply $cvePatches/CVE-2017-0786/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
cd $base
