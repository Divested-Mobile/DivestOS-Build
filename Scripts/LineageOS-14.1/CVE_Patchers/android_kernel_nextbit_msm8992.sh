#!/bin/bash
cd $base"kernel/nextbit/msm8992"
git apply $cvePatches/CVE-2014-9904/ANY/0.patch
git apply $cvePatches/CVE-2016-6672/ANY/0.patch
git apply $cvePatches/CVE-2017-0648/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
git apply $cvePatches/LVT-2017-0003/3.10/0.patch
cd $base
