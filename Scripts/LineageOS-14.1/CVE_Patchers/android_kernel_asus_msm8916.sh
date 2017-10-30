#!/bin/bash
cd $base"kernel/asus/msm8916"
git apply $cvePatches/CVE-2014-9781/ANY/0.patch
git apply $cvePatches/CVE-2016-10233/3.10/1.patch
git apply $cvePatches/CVE-2016-3134/3.10/0.patch
git apply $cvePatches/CVE-2016-3857/3.10/0.patch
git apply $cvePatches/CVE-2016-6672/ANY/0.patch
git apply $cvePatches/CVE-2016-8394/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
cd $base
