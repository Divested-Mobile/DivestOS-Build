#!/bin/bash
cd $base"kernel/samsung/msm8974"
git apply $cvePatches/CVE-2016-1583/ANY/0001.patch
git apply $cvePatches/CVE-2016-2475/ANY/0001.patch
git apply $cvePatches/CVE-2016-4578/ANY/0001.patch
git apply $cvePatches/CVE-2017-0611/3.4/0001.patch
git apply $cvePatches/CVE-2017-0750/ANY/0001.patch
git apply $cvePatches/CVE-2017-16525/ANY/0002.patch
git apply $cvePatches/CVE-2017-16526/ANY/0001.patch
git apply $cvePatches/CVE-2017-16532/ANY/0001.patch
git apply $cvePatches/CVE-2017-16533/ANY/0001.patch
git apply $cvePatches/CVE-2017-16535/ANY/0001.patch
git apply $cvePatches/CVE-2017-16643/ANY/0001.patch
git apply $cvePatches/CVE-2017-16650/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0001.patch
git apply $cvePatches/CVE-2017-16USB/ANY/0005.patch
git apply $cvePatches/CVE-2017-8246/3.4/0002.patch
git apply $cvePatches/CVE-2017-8254/3.4/0001.patch
cd $base
