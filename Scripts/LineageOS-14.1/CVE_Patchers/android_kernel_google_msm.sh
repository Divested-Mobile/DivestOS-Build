#!/bin/bash
cd $base"kernel/google/msm"
git apply $cvePatches/CVE-2014-9781/ANY/0.patch
git apply $cvePatches/CVE-2015-1593/ANY/0.patch
git apply $cvePatches/CVE-2016-3859/ANY/0.patch
git apply $cvePatches/CVE-2016-8402/3.4/1.patch
git apply $cvePatches/CVE-2016-8404/ANY/0.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0710/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/CVE-2017-0751/ANY/0.patch
git apply $cvePatches/CVE-2017-0786/ANY/0.patch
git apply $cvePatches/CVE-2017-13080/ANY/0.patch
git apply $cvePatches/CVE-2017-15265/ANY/0.patch
cd $base
