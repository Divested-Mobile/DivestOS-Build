#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply $cvePatches/CVE-2016-0801/ANY/0001.patch
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2017-0430/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply $cvePatches/CVE-2017-6348/^4.9/0001.patch
cd $base
