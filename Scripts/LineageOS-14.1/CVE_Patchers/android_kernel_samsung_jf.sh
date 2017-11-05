#!/bin/bash
cd $base"kernel/samsung/jf"
git apply $cvePatches/CVE-2016-10233/ANY/0.patch
git apply $cvePatches/CVE-2016-2185/ANY/0.patch
git apply $cvePatches/CVE-2016-2186/ANY/0.patch
git apply $cvePatches/CVE-2016-2475/ANY/0.patch
git apply $cvePatches/CVE-2016-3854/ANY/0.patch
git apply $cvePatches/CVE-2016-6672/ANY/0.patch
git apply $cvePatches/CVE-2016-8402/3.4/1.patch
git apply $cvePatches/CVE-2016-8404/ANY/0.patch
git apply $cvePatches/CVE-2017-0430/ANY/0.patch
git apply $cvePatches/CVE-2017-0573/ANY/0.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0706/ANY/0.patch
git apply $cvePatches/CVE-2017-0710/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-0751/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-0791/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
git apply $cvePatches/CVE-2017-5970/ANY/0.patch
git apply $cvePatches/CVE-2017-7487/ANY/0.patch
cd $base
