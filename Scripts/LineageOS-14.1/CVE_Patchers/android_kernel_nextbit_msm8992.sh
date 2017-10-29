#!/bin/bash
cd $base"kernel/nextbit/msm8992"
git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2014-9904/0.patch
git apply $cvePatches/CVE-2016-6672/0.patch
git apply $cvePatches/CVE-2017-0750/0.patch
git apply $cvePatches/CVE-2017-12153/0.patch
git apply $cvePatches/CVE-2017-6345/0.patch
cd $base
