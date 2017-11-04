#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatches/CVE-2016-3672/ANY/0.patch
git apply $cvePatches/CVE-2017-0430/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-6348/ANY/0.patch
cd $base
