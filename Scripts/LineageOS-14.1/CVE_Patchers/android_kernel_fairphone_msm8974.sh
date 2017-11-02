#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply --3way $cvePatches/CVE-2014-0196/3.4/2.patch
git apply --3way $cvePatches/CVE-2014-8160/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9420/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9790/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9868/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9876/3.4/1.patch
git apply --3way $cvePatches/CVE-2014-9889/3.4/1.patch
git apply --3way $cvePatches/CVE-2015-8939/ANY/0.patch
git apply --3way $cvePatches/CVE-2015-8943/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-0821/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-3672/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-5195/3.4/0.patch
git apply --3way $cvePatches/CVE-2017-0430/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0648/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0750/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0786/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-13080/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-15265/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-6348/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8890/3.4/0.patch
cd $base
