#!/bin/bash
cd $base"kernel/htc/flounder"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9892/0.patch
git apply $cvePatches/CVE-2014-9900/0.patch
git apply $cvePatches/CVE-2015-4177/0.patch
git apply $cvePatches/CVE-2015-8944/0.patch
git apply $cvePatches/CVE-2016-0819/0.patch
git apply $cvePatches/CVE-2016-8453/0.patch
git apply $cvePatches/CVE-2016-8464/0.patch
git apply $cvePatches/CVE-2016-8650/0.patch
git apply $cvePatches/CVE-2016-9604/0.patch
git apply $cvePatches/CVE-2017-0449/0.patch
git apply $cvePatches/CVE-2017-0537/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-0794/0.patch
git apply $cvePatches/CVE-2017-1000365/0.patch
git apply $cvePatches/CVE-2017-10996/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-15265/0.patch
git apply $cvePatches/CVE-2017-2671/0.patch
git apply $cvePatches/CVE-2017-5669/0.patch
git apply $cvePatches/CVE-2017-5970/0.patch
git apply $cvePatches/CVE-2017-6345/0.patch
git apply $cvePatches/CVE-2017-6348/0.patch
git apply $cvePatches/CVE-2017-6951/0.patch
git apply $cvePatches/CVE-2017-7472/0.patch
git apply $cvePatches/CVE-2017-9242/0.patch
cd $base
