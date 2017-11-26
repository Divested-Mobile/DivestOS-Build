#!/bin/bash
cd $base"kernel/nextbit/msm8992"
git apply $cvePatches/CVE-2014-9904/ANY/0001.patch
git apply $cvePatches/CVE-2016-6672/ANY/0001.patch
git apply $cvePatches/CVE-2016-6693/ANY/0001.patch
git apply $cvePatches/CVE-2016-6696/ANY/0001.patch
git apply $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-0861/3.10/0001.patch
git apply $cvePatches/CVE-2017-0862/3.10/0001.patch
git apply $cvePatches/CVE-2017-11090/ANY/0001.patch
git apply $cvePatches/CVE-2017-11600/3.10/0001.patch
git apply $cvePatches/CVE-2017-12153/3.2-^3.16/0001.patch
git apply $cvePatches/CVE-2017-16526/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16531/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16532/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16533/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16535/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16537/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16538/^4.13/0001.patch
git apply $cvePatches/CVE-2017-16538/^4.13/0002.patch
git apply $cvePatches/CVE-2017-16643/3.5+/0001.patch
git apply $cvePatches/CVE-2017-16645/ANY/0001.patch
git apply $cvePatches/CVE-2017-16650/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0003.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0006.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0007.patch
git apply $cvePatches/CVE-2017-6345/^4.9/0001.patch
git apply $cvePatches/CVE-2017-7541/3.10/0002.patch
git apply $cvePatches/LVT-2017-0003/3.10/0001.patch
cd $base
