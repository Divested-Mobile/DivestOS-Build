#!/bin/bash
cd $base"kernel/samsung/jf"
git apply $cvePatches/CVE-2012-6703/ANY/0001.patch
git apply $cvePatches/CVE-2016-0801/ANY/0001.patch
git apply $cvePatches/CVE-2016-10233/ANY/0001.patch
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2016-2185/ANY/0001.patch
git apply $cvePatches/CVE-2016-2186/ANY/0001.patch
git apply $cvePatches/CVE-2016-2475/ANY/0001.patch
git apply $cvePatches/CVE-2016-3854/ANY/0001.patch
git apply $cvePatches/CVE-2016-3857/ANY/0001.patch
git apply $cvePatches/CVE-2016-3865/ANY/0001.patch
git apply $cvePatches/CVE-2016-3894/ANY/0001.patch
git apply $cvePatches/CVE-2016-6672/ANY/0001.patch
git apply $cvePatches/CVE-2016-6791/ANY/0001.patch
git apply $cvePatches/CVE-2016-8402/3.4/0001.patch
git apply $cvePatches/CVE-2016-8404/ANY/0001.patch
git apply $cvePatches/CVE-2017-0430/ANY/0001.patch
git apply $cvePatches/CVE-2017-0524/ANY/0001.patch
git apply $cvePatches/CVE-2017-0571/ANY/0001.patch
git apply $cvePatches/CVE-2017-0573/ANY/0001.patch
git apply $cvePatches/CVE-2017-0648/ANY/0001.patch
git apply $cvePatches/CVE-2017-0706/ANY/0001.patch
git apply $cvePatches/CVE-2017-0710/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-0751/ANY/0001.patch
git apply $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply $cvePatches/CVE-2017-0791/ANY/0001.patch
git apply $cvePatches/CVE-2017-1000380/^4.11/0001.patch
git apply $cvePatches/CVE-2017-10663/ANY/0002.patch
git apply $cvePatches/CVE-2017-15265/^4.14/0001.patch
git apply $cvePatches/CVE-2017-5970/ANY/0001.patch
git apply $cvePatches/CVE-2017-7487/ANY/0001.patch
cd $base
