#!/bin/bash
cd $base"frameworks/base"
git apply $cvePatchesAndroid/CVE-2017-0845/5.0.2-^7.1.2/0001.patch
git apply $cvePatchesAndroid/CVE-2017-0880/7.0-^7.1.2/0002.patch
cd $base
