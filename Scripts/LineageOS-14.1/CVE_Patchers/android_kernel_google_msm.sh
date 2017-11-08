#!/bin/bash
cd $base"kernel/google/msm"
git apply --whitespace=fix $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2013-4738/ANY/0002.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9781/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2015-1593/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-3857/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-3894/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8402/3.4/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8404/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0710/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0751/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-13080/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-15265/^4.14/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-7187/ANY/0001.patch
cd $base
