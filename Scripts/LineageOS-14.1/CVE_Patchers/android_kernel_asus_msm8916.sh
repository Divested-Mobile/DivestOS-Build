#!/bin/bash
cd $base"kernel/asus/msm8916"
git apply $cvePatches"CVE-2014-9781"/*.patch && echo 'Applied fix for CVE-2014-9781'
git apply $cvePatches"CVE-2016-3134"/*.patch && echo 'Applied fix for CVE-2016-3134'
git apply $cvePatches"CVE-2016-6672"/*.patch && echo 'Applied fix for CVE-2016-6672'
git apply $cvePatches"CVE-2016-8394"/*.patch && echo 'Applied fix for CVE-2016-8394'
git apply $cvePatches"CVE-2017-0750"/*.patch && echo 'Applied fix for CVE-2017-0750'
cd $base
