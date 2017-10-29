#!/bin/bash
cd $base"kernel/nextbit/msm8992"
git apply $cvePatches"CVE-2014-9904"/*.patch && echo 'Applied fix for CVE-2014-9904'
git apply $cvePatches"CVE-2016-6672"/*.patch && echo 'Applied fix for CVE-2016-6672'
git apply $cvePatches"CVE-2017-0750"/*.patch && echo 'Applied fix for CVE-2017-0750'
git apply $cvePatches"CVE-2017-12153"/*.patch && echo 'Applied fix for CVE-2017-12153'
git apply $cvePatches"CVE-2017-6345"/*.patch && echo 'Applied fix for CVE-2017-6345'
cd $base
