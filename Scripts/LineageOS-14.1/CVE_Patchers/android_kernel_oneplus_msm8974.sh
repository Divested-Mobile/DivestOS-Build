#!/bin/bash
cd $base"kernel/oneplus/msm8974"
git apply --whitespace=fix $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9781/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9880/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-0801/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-2443/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-6672/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8404/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0510/3.4/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0524/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0610/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0751/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-1000380/^4.11/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-11000/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-11048/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-11059/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-13080/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-15265/^4.14/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-7487/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-8247/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-9242/^4.11/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-9684/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-9706/ANY/0001.patch
cd $base
