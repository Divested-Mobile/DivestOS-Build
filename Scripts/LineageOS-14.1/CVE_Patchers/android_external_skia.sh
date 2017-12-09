#!/bin/bash
cd $base"external/skia"
git apply $cvePatchesAndroid/CVE-2017-0880/7.0-^7.1.2/0001.patch
cd $base
