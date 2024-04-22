#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2017-2023 Divested Computing Group
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
umask 0022;
set -uo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

#Attempts to patch kernels to be more secure

#Is this the best way to do it? No. Is it the proper way to do it? No. Is it better then nothing? YES!

#Troubleshooting a patch
##If you get an error like the following
#> ../../../../../../kernel/nextbit/msm8992/drivers/media/platform/msm/camera_v2/sensor/actuator/msm_actuator.c:1116:32: error: 'ACTUATOR_POWER_UP' undeclared (first use in this function)
#$ cd $DOS_CVES_LINUX
#$ grep "ACTUATOR_POWER_UP" . -Ri
#> ./CVE-2018-3585/3.10/0001.patch:+	if (a_ctrl->actuator_state != ACTUATOR_POWER_UP) {
#$ nano $DOS_SCRIPTS_CVES/android_kernel_nextbit_msm8992.sh
# Comment out CVE-2018-3585/3.10/0001.patch

echo "Patching CVEs...";

cd "$DOS_BUILD_BASE";
for patcher in "$DOS_SCRIPTS_CVES"/*.sh; do
	echo "Running $patcher";
	source "$patcher" || true;
done;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Patched CVEs\e[0m";
