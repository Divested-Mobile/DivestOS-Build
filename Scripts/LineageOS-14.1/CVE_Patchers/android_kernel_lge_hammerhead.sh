#!/bin/bash
cd $base"kernel/lge/hammerhead"
git apply $cvePatches/CVE-2014-9881/ANY/0.patch
git apply $cvePatches/CVE-2015-1593/ANY/0.patch
git apply $cvePatches/CVE-2016-5829/ANY/0.patch
git apply $cvePatches/CVE-2016-8650/ANY/0.patch
git apply $cvePatches/CVE-2016-9604/ANY/0.patch
git apply $cvePatches/CVE-2017-0611/ANY/0.patch
git apply $cvePatches/CVE-2017-0710/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-0751/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-13080/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-2671/ANY/0.patch
git apply $cvePatches/CVE-2017-5970/ANY/0.patch
git apply $cvePatches/CVE-2017-6074/ANY/0.patch
git apply $cvePatches/CVE-2017-6345/ANY/0.patch
git apply $cvePatches/CVE-2017-6348/ANY/0.patch
git apply $cvePatches/CVE-2017-6951/ANY/0.patch
git apply $cvePatches/CVE-2017-7487/ANY/0.patch
git apply $cvePatches/CVE-2017-8247/ANY/0.patch
git apply $cvePatches/CVE-2017-8890/3.4/0.patch
git apply $cvePatches/CVE-2017-9242/ANY/0.patch
cd $base
