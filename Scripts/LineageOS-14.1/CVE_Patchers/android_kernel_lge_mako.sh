#!/bin/bash
cd $base"kernel/lge/mako"
git apply $cvePatches/CVE-2016-8402/3.4/1.patch
git apply $cvePatches/CVE-2016-8404/ANY/0.patch
cd $base
