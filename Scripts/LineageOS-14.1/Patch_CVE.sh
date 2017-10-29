#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Attempts to patch kernels to be more secure

echo "Patching CVEs..."

source $cveScripts"*.sh";

cd $base
echo "Patched CVEs!"
