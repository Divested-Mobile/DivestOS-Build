#!/bin/bash
cd $base"kernel/lge/mako"
git apply --3way $cvePatches/CVE-2012-6701/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-8160/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9777/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9778/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9870/ANY/0.patch
git apply --3way $cvePatches/CVE-2015-7515/3.2-^4.4/1.patch
git apply --3way $cvePatches/CVE-2016-0821/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-8402/3.4/1.patch
git apply --3way $cvePatches/CVE-2016-8404/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-9793/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0648/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8890/3.4/0.patch
cd $base
