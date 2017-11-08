#!/bin/bash
cd $base"kernel/lge/mako"
git apply $cvePatches/CVE-2013-4738/ANY/0002.patch
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2016-3857/ANY/0001.patch
git apply $cvePatches/CVE-2016-3894/ANY/0001.patch
git apply $cvePatches/CVE-2016-8402/3.4/0001.patch
git apply $cvePatches/CVE-2016-8404/ANY/0001.patch
git apply $cvePatches/CVE-2016-9793/ANY/0001.patch
cd $base
