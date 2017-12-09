#!/bin/bash
cd $base"packages/apps/Settings"
git apply $cvePatchesAndroid/CVE-2017-13159/5.1.1-^8.0/0001.patch
cd $base
