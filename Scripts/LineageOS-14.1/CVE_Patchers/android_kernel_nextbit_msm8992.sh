#!/bin/bash
cd $base"kernel/nextbit/msm8992"
git apply --whitespace=fix $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9904/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-6672/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-6693/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-6696/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-6345/^4.9/0001.patch
git apply --whitespace=fix $cvePatches/LVT-2017-0003/3.10/0001.patch
cd $base
