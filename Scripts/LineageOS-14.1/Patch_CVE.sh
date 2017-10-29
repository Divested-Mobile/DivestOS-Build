#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Attempts to patch kernels to be more secure

echo "Patching CVEs..."

cd $base
for patcher in $cveScripts/*.sh; do
	echo "Running " $patcher;
	source $patcher;
done;

cd $base
echo "Patched CVEs!"
