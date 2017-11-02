#!/bin/bash
cd $base"kernel/oneplus/msm8974"
git apply --3way $cvePatches/CVE-2012-6701/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-0196/3.4/2.patch
git apply --3way $cvePatches/CVE-2014-8160/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9420/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9781/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9790/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9868/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9876/3.4/1.patch
git apply --3way $cvePatches/CVE-2014-9880/ANY/0.patch
git apply --3way $cvePatches/CVE-2015-8939/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-0821/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-2443/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-3672/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-5195/3.4/0.patch
git apply --3way $cvePatches/CVE-2016-6672/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-8404/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0510/3.4/3.patch
git apply --3way $cvePatches/CVE-2017-0648/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0750/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0751/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0786/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-11000/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-13080/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-15265/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-7487/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8247/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8890/3.4/0.patch
git apply --3way $cvePatches/CVE-2017-9242/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-9725/ANY/0.patch
git apply --3way $cvePatches/LVT-2017-0002/3.4/0.patch
git apply --3way $cvePatches/LVT-2017-0004/3.4/0.patch
cd $base
