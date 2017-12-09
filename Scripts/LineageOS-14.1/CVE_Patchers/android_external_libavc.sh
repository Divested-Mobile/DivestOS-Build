#!/bin/bash
cd $base"external/libavc"
git apply $cvePatchesAndroid/CVE-2017-0874/6.0-^8.0/0001.patch
cd $base
