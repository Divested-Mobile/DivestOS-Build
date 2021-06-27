#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2020 Divested Computing Group
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

#Last verified: 2018-07-10

patchAllKernels() {
	startPatcher "kernel_zte_msm8930";
}
export -f patchAllKernels;

resetWorkspace() {
	umask 0022;
	repo forall -c 'git add -A && git reset --hard' && rm -rf out && repo sync -j20 --force-sync;
}
export -f resetWorkspace;

scanWorkspaceForMalware() {
	local scanQueue="$DOS_BUILD_BASE/abi $DOS_BUILD_BASE/android $DOS_BUILD_BASE/bionic $DOS_BUILD_BASE/bootable $DOS_BUILD_BASE/build $DOS_BUILD_BASE/dalvik $DOS_BUILD_BASE/device $DOS_BUILD_BASE/hardware $DOS_BUILD_BASE/libcore $DOS_BUILD_BASE/libnativehelper $DOS_BUILD_BASE/ndk $DOS_BUILD_BASE/packages $DOS_BUILD_BASE/pdk $DOS_BUILD_BASE/sdk $DOS_BUILD_BASE/system";
	scanQueue=$scanQueue" $DOS_BUILD_BASE/vendor/cm $DOS_BUILD_BASE/vendor/cmsdk";
	scanForMalware true "$scanQueue";
}
export -f scanWorkspaceForMalware;

buildDevice() {
	cd "$DOS_BUILD_BASE";
	export OTA_PACKAGE_SIGNING_KEY="$DOS_SIGNING_KEYS/$1/releasekey";
	brunch "cm_$1-user" && processRelease $1 false;
}
export -f buildDevice;

buildDeviceDebug() {
	cd "$DOS_BUILD_BASE";
	unset OTA_PACKAGE_SIGNING_KEY;
	brunch "cm_$1-eng";
}
export -f buildDeviceDebug;

buildAll() {
	umask 0022;
	cd "$DOS_BUILD_BASE";
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanWorkspaceForMalware; fi;
	if [ "$DOS_OPTIMIZE_IMAGES" = true ]; then optimizeImagesRecursive "$DOS_BUILD_BASE"; fi;
	brunch lineage_nex-user && processRelease nex false; #broken encryption
}
export -f buildAll;

patchWorkspace() {
	umask 0022;
	if [ "$DOS_MALWARE_SCAN_ENABLED" = true ]; then scanForMalware false "$DOS_PREBUILT_APPS $DOS_BUILD_BASE/build $DOS_BUILD_BASE/device $DOS_BUILD_BASE/vendor/cm"; fi;
	sed -i "s/'git', 'show', '-q'/'git', 'show'/" build/tools/repopick.py; #fix for old git versions
	source build/envsetup.sh;
	repopick -ift asb-2018.09-cm11-qcom; #TODO: move in tree

	source "$DOS_SCRIPTS/Patch.sh";
	source "$DOS_SCRIPTS/Defaults.sh";
	source "$DOS_SCRIPTS/Rebrand.sh";
	source "$DOS_SCRIPTS_COMMON/Optimize.sh";
	source "$DOS_SCRIPTS_COMMON/Deblob.sh";
	source "$DOS_SCRIPTS_COMMON/Patch_CVE.sh";
	source build/envsetup.sh;
}
export -f patchWorkspace;
