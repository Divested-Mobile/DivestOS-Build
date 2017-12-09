#!/bin/bash
cd $base"external/libmpeg2"
git apply $cvePatchesAndroid/CVE-2017-0873/6.0-^8.0/0001.patch
git apply $cvePatchesAndroid/CVE-2017-13148/6.0-^8.0/0001.patch
git apply $cvePatchesAndroid/CVE-2017-13150/6.0-^8.0/0001.patch
git apply $cvePatchesAndroid/CVE-2017-13151/6.0-^8.0/0001.patch
cd $base
