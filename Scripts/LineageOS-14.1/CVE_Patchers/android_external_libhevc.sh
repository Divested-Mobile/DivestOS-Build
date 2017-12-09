#!/bin/bash
cd $base"external/libhevc"
git apply $cvePatchesAndroid/CVE-2017-13149/5.1.1-^8.0/0001.patch
cd $base
