#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Spot Communications, Inc.
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

#Troubleshooting a patch
##If you get an error like the following
#> ../../../../../../kernel/nextbit/msm8992/drivers/media/platform/msm/camera_v2/sensor/actuator/msm_actuator.c:1116:32: error: 'ACTUATOR_POWER_UP' undeclared (first use in this function)
#$ cd $cvePatchesLinux
#$ grep "ACTUATOR_POWER_UP" . -Ri
#> ./CVE-2018-3585/3.10/0001.patch:+	if (a_ctrl->actuator_state != ACTUATOR_POWER_UP) {
#$ nano $cveScripts/android_kernel_nextbit_msm8992.sh
# Comment out CVE-2018-3585/3.10/0001.patch

echo "Patching CVEs...";

cd $base;
for patcher in $cveScripts/*.sh; do
	echo "Running " $patcher;
	source $patcher;
done;

cd $base;
echo "Patched CVEs!";
