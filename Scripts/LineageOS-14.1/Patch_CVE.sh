#!/bin/bash
#Copyright (c) 2017 Spot Communications, Inc.

#Attempts to patch kernels to be more secure

#Is this the best way to do it? No. Is it the proper way to do it? No. Do I wish device maintainers would do it? Yes. Is it better then nothing? YES!

echo "Patching CVEs..."

cd $base
for patcher in $cveScripts/*.sh; do
	echo "Running " $patcher;
	source $patcher;
done;

cd $base
echo "Patched CVEs!"
