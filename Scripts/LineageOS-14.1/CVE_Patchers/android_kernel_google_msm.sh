#!/bin/bash
cd $base"kernel/google/msm"
git apply $cvePatches"CVE-2014-9781"/*.patch && echo 'Applied fix for CVE-2014-9781'
git apply $cvePatches"CVE-2015-1593"/*.patch && echo 'Applied fix for CVE-2015-1593'
git apply $cvePatches"CVE-2016-3134"/*.patch && echo 'Applied fix for CVE-2016-3134'
git apply $cvePatches"CVE-2016-3859"/*.patch && echo 'Applied fix for CVE-2016-3859'
git apply $cvePatches"CVE-2016-8404"/*.patch && echo 'Applied fix for CVE-2016-8404'
git apply $cvePatches"CVE-2017-0750"/*.patch && echo 'Applied fix for CVE-2017-0750'
git apply $cvePatches"CVE-2017-0751"/*.patch && echo 'Applied fix for CVE-2017-0751'
git apply $cvePatches"CVE-2017-0786"/*.patch && echo 'Applied fix for CVE-2017-0786'
git apply $cvePatches"CVE-2017-12153"/*.patch && echo 'Applied fix for CVE-2017-12153'
git apply $cvePatches"CVE-2017-15265"/*.patch && echo 'Applied fix for CVE-2017-15265'
cd $base
