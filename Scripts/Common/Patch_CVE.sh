#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017 Spot Communications, Inc.
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
