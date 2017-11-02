#!/bin/bash
cd $base"kernel/lge/hammerhead"
git apply --3way $cvePatches/CVE-2012-6701/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-8160/3.2-^3.18/1.patch
git apply --3way $cvePatches/CVE-2014-9790/ANY/0.patch
git apply --3way $cvePatches/CVE-2014-9876/3.4/1.patch
git apply --3way $cvePatches/CVE-2014-9881/ANY/0.patch
git apply --3way $cvePatches/CVE-2015-1593/ANY/0.patch
git apply --3way $cvePatches/CVE-2015-7515/3.2-^4.4/1.patch
git apply --3way $cvePatches/CVE-2015-8939/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-0821/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-2443/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-3841/3.4/0.patch
git apply --3way $cvePatches/CVE-2016-3842/3.4/0.patch
git apply --3way $cvePatches/CVE-2016-5829/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-8650/ANY/0.patch
git apply --3way $cvePatches/CVE-2016-9604/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0611/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0648/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0710/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0750/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0751/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-0786/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-15265/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-2671/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-5970/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-6074/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-6345/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-6348/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-6951/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-7487/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8247/ANY/0.patch
git apply --3way $cvePatches/CVE-2017-8890/3.4/0.patch
git apply --3way $cvePatches/CVE-2017-9242/ANY/0.patch
cd $base
