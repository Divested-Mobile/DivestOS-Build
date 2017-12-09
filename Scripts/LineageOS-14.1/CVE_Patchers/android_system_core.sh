#!/bin/bash
cd $base"system/core"
git apply $cvePatchesAndroid/CVE-2017-13156/5.1.1-^8.0/0001.patch
cd $base
