#!/bin/bash
cd $base"kernel/htc/msm8974"
git apply $cvePatches/CVE-2014-1739/ANY/0001.patch
git apply $cvePatches/CVE-2014-9715/^3.14/0002.patch
git apply $cvePatches/CVE-2014-9781/ANY/0001.patch
git apply $cvePatches/CVE-2015-1593/ANY/0001.patch
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2016-2443/ANY/0001.patch
git apply $cvePatches/CVE-2016-8404/ANY/0001.patch
git apply $cvePatches/CVE-2017-0610/ANY/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-0786/ANY/0001.patch
git apply $cvePatches/CVE-2017-12153/3.2-^3.16/0001.patch
git apply $cvePatches/CVE-2017-15265/^4.14/0001.patch
cd $base
