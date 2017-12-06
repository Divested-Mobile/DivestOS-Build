#!/bin/bash
cd $base"kernel/samsung/msm8974"
git apply $cvePatches/CVE-2016-2475/ANY/0001.patch
git apply $cvePatches/CVE-2016-4578/ANY/0001.patch
git apply $cvePatches/CVE-2017-0611/3.4/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-16525/^4.13/0002.patch
git apply $cvePatches/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16535/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16650/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatches/CVE-2017-8246/3.4/0002.patch
git apply $cvePatches/CVE-2017-8254/3.4/0001.patch
git apply $cvePatches/CVE-2017-8254/3.4/0002.patch
git apply $cvePatches/Untracked/ANY/0008-nfsd-check-for-oversized-NFSv2-v3-arguments.patch
cd $base
