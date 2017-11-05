#!/bin/bash
cd $base"kernel/samsung/msm8974"
git apply $cvePatches/CVE-2016-2475/ANY/0.patch
git apply $cvePatches/CVE-2017-0750/ANY/0.patch
cd $base
