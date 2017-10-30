#!/bin/bash
cd $base"kernel/oneplus/msm8974"
git apply $cvePatches/CVE-2014-9781/ANY/0.patch
git apply $cvePatches/CVE-2014-9876/3.4/1.patch
git apply $cvePatches/CVE-2014-9880/ANY/0.patch
git apply $cvePatches/CVE-2016-2443/ANY/0.patch
git apply $cvePatches/CVE-2016-3672/ANY/0.patch
git apply $cvePatches/CVE-2016-6672/ANY/0.patch
git apply $cvePatches/CVE-2016-8404/ANY/0.patch
git apply $cvePatches/CVE-2017-0510/3.4/3.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-0751/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-11000/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-7487/ANY/0.patch
git apply $cvePatches/CVE-2017-8247/ANY/0.patch
git apply $cvePatches/CVE-2017-9242/ANY/0.patch
git apply $cvePatches/CVE-2017-9725/ANY/0.patch
cd $base
