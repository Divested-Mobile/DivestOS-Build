#!/bin/bash
cd $base"kernel/fairphone/msm8974"
git apply $cvePatches"CVE-2016-3134"/*.patch && echo 'Applied fix for CVE-2016-3134'
git apply $cvePatches"CVE-2016-3672"/*.patch && echo 'Applied fix for CVE-2016-3672'
git apply $cvePatches"CVE-2017-0430"/*.patch && echo 'Applied fix for CVE-2017-0430'
git apply $cvePatches"CVE-2017-0750"/*.patch && echo 'Applied fix for CVE-2017-0750'
git apply $cvePatches"CVE-2017-0786"/*.patch && echo 'Applied fix for CVE-2017-0786'
git apply $cvePatches"CVE-2017-11059"/*.patch && echo 'Applied fix for CVE-2017-11059'
git apply $cvePatches"CVE-2017-12153"/*.patch && echo 'Applied fix for CVE-2017-12153'
git apply $cvePatches"CVE-2017-15265"/*.patch && echo 'Applied fix for CVE-2017-15265'
git apply $cvePatches"CVE-2017-6348"/*.patch && echo 'Applied fix for CVE-2017-6348'
cd $base
