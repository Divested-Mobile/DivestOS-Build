#!/bin/bash
cd $base"kernel/htc/flounder"
git apply --whitespace=fix $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9892/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2014-9900/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2015-7515/^4.4/0002.patch
git apply --whitespace=fix $cvePatches/CVE-2015-8944/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2015-8955/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-0819/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-2475/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8453/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8464/3.10/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-8650/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-9604/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0449/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0537/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0794/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-1000365/3.10/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-1000380/^4.11/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-10996/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-15265/^4.14/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-2671/^4.10/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-5669/^4.9/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-5970/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-6345/^4.9/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-6348/^4.9/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-6951/^3.14/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-7472/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-9242/^4.11/0001.patch
git apply --whitespace=fix $cvePatches/LVT-2017-0003/3.10/0001.patch
cd $base
