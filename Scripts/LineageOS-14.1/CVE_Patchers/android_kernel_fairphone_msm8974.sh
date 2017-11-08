#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatches/CVE-2016-0801/ANY/0001.patch
git apply $cvePatches/CVE-2017-0430/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply $cvePatches/CVE-2017-16525/ANY/0002.patch
git apply $cvePatches/CVE-2017-16526/ANY/0001.patch
git apply $cvePatches/CVE-2017-16532/ANY/0001.patch
git apply $cvePatches/CVE-2017-16533/ANY/0001.patch
git apply $cvePatches/CVE-2017-16535/ANY/0001.patch
git apply $cvePatches/CVE-2017-16643/ANY/0001.patch
git apply $cvePatches/CVE-2017-16650/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatches/CVE-2017-6348/^4.9/0001.patch
git apply $cvePatches/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
cd $base
