#!/bin/bash
cd $base"kernel/samsung/msm8974"
git apply --whitespace=fix $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-2475/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2016-4578/ANY/0001.patch
git apply --whitespace=fix $cvePatches/CVE-2017-0750/ANY/0001.patch
cd $base
