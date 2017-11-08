#!/bin/bash
cd $base"kernel/asus/msm8916"
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2016-6672/ANY/0001.patch
git apply $cvePatches/CVE-2016-6693/ANY/0001.patch
git apply $cvePatches/CVE-2016-6696/ANY/0001.patch
git apply $cvePatches/CVE-2016-8394/ANY/0001.patch
git apply $cvePatches/CVE-2016-8481/ANY/0003.patch
git apply $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-16526/ANY/0001.patch
git apply $cvePatches/CVE-2017-16531/ANY/0001.patch
git apply $cvePatches/CVE-2017-16532/ANY/0001.patch
git apply $cvePatches/CVE-2017-16533/ANY/0001.patch
git apply $cvePatches/CVE-2017-16535/ANY/0001.patch
git apply $cvePatches/CVE-2017-16538/ANY/0001.patch
git apply $cvePatches/CVE-2017-16538/ANY/0002.patch
git apply $cvePatches/CVE-2017-16643/ANY/0001.patch
git apply $cvePatches/CVE-2017-16645/ANY/0001.patch
git apply $cvePatches/CVE-2017-16650/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0003.patch
git apply $cvePatches/CVE-2017-5972/ANY/0002.patch
git apply $cvePatches/LVT-2017-0003/3.10/0001.patch
cd $base
