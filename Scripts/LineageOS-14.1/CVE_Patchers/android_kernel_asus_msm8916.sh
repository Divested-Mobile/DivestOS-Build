#!/bin/bash
cd $base"kernel/asus/msm8916"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9781/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-6672/0.patch
git apply $cvePatches/CVE-2016-8394/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
cd $base
