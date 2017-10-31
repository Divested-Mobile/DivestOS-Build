#!/bin/bash
cd $base"kernel/motorola/msm8916"
git apply $cvePatches/CVE-2014-9420/ANY/0.patch
git apply $cvePatches/CVE-2014-9781/ANY/0.patch
git apply $cvePatches/CVE-2015-1593/ANY/0.patch
git apply $cvePatches/CVE-2015-7515/ANY/0.patch
git apply $cvePatches/CVE-2015-8967/ANY/0.patch
git apply $cvePatches/CVE-2016-10231/ANY/1.patch
git apply $cvePatches/CVE-2016-10233/3.10/1.patch
git apply $cvePatches/CVE-2016-3134/3.10/0.patch
git apply $cvePatches/CVE-2016-3137/ANY/0.patch
git apply $cvePatches/CVE-2016-3672/ANY/0.patch
git apply $cvePatches/CVE-2016-3857/3.10/0.patch
git apply $cvePatches/CVE-2016-3865/ANY/0.patch
git apply $cvePatches/CVE-2016-3865/ANY/1.patch
git apply $cvePatches/CVE-2016-3902/ANY/0.patch
git apply $cvePatches/CVE-2016-5859/ANY/0.patch
git apply $cvePatches/CVE-2016-5867/ANY/0.patch
git apply $cvePatches/CVE-2016-6672/ANY/0.patch
git apply $cvePatches/CVE-2017-0457/3.10/0.patch
git apply $cvePatches/CVE-2017-0457/3.10/1.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-6345/ANY/0.patch
git apply $cvePatches/CVE-2017-6348/ANY/0.patch
git apply $cvePatches/LVT-2017-0003/3.10/0.patch
cd $base
