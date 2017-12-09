#!/bin/bash
cd $base"frameworks/av"
git apply $cvePatchesAndroid/CVE-2017-0837/5.1.1-^8.0/0001.patch
git apply $cvePatchesAndroid/CVE-2017-0879/5.1.1-^8.0/0001.patch
git apply $cvePatchesAndroid/CVE-2017-13152/5.1.1-^8.0/0001.patch
cd $base
