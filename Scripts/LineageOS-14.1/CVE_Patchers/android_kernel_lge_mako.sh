#!/bin/bash
cd $base"kernel/lge/mako"
#git apply $cvePatches/CVE-2012-6703/0.patch
git apply $cvePatches/CVE-2016-3134/0.patch
git apply $cvePatches/CVE-2016-8404/0.patch
git apply $cvePatches/CVE-2016-9793/0.patch
cd $base
