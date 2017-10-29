#!/bin/bash
cd $base"kernel/lge/mako"
git apply $cvePatches"CVE-2016-3134"/*.patch && echo 'Applied fix for CVE-2016-3134'
git apply $cvePatches"CVE-2016-8404"/*.patch && echo 'Applied fix for CVE-2016-8404'
git apply $cvePatches"CVE-2016-9793"/*.patch && echo 'Applied fix for CVE-2016-9793'
cd $base
