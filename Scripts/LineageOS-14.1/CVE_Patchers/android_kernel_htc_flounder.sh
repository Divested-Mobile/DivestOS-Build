#!/bin/bash
cd $base"kernel/htc/flounder"
git apply $cvePatches/CVE-2014-9892/ANY/0.patch
git apply $cvePatches/CVE-2014-9900/ANY/0.patch
git apply $cvePatches/CVE-2015-4177/ANY/0.patch
git apply $cvePatches/CVE-2015-7515/ANY/0.patch
git apply $cvePatches/CVE-2015-8944/ANY/0.patch
git apply $cvePatches/CVE-2016-2475/ANY/0.patch
git apply $cvePatches/CVE-2016-8453/ANY/0.patch
git apply $cvePatches/CVE-2016-8464/3.10/0.patch
git apply $cvePatches/CVE-2016-8650/ANY/0.patch
git apply $cvePatches/CVE-2016-9604/ANY/0.patch
git apply $cvePatches/CVE-2017-0449/ANY/0.patch
git apply $cvePatches/CVE-2017-0537/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-1000365/3.10/0.patch
git apply $cvePatches/CVE-2017-10996/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-2671/ANY/0.patch
git apply $cvePatches/CVE-2017-5669/ANY/0.patch
git apply $cvePatches/CVE-2017-5970/ANY/0.patch
git apply $cvePatches/CVE-2017-6345/ANY/0.patch
git apply $cvePatches/CVE-2017-6348/ANY/0.patch
git apply $cvePatches/CVE-2017-6951/ANY/0.patch
git apply $cvePatches/CVE-2017-7472/ANY/0.patch
git apply $cvePatches/CVE-2017-9242/ANY/0.patch
git apply $cvePatches/LVT-2017-0003/3.10/0.patch
cd $base
