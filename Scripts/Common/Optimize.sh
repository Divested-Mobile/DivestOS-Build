#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2017-2023 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.
umask 0022;
set -euo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

#Attempts to increase performance and battery life
#Last verified: 2021-10-16

echo "Optimizing...";

if enter "frameworks/base"; then
sed -i 's/ScaleSetting = 1.0f;/ScaleSetting = 0.5f;/' services/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
sed -i 's/AnimationScale = 1.0f;/AnimationScale = 0.5f;/' services/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
sed -i 's/DurationnScale = 1.0f;/DurationScale = 0.5f;/' services/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
sed -i 's/ScaleSetting = 1.0f;/ScaleSetting = 0.5f;/' services/core/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
sed -i 's/AnimationScale = 1.0f;/AnimationScale = 0.5f;/' services/core/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
sed -i 's/DurationnScale = 1.0f;/DurationScale = 0.5f;/' services/core/java/com/android/server/wm/WindowManagerService.java &>/dev/null || true;
#sed -i 's|||'
fi;

#if enter "kernel"; then
#sed -i "s/#define VM_MAX_READAHEAD\t128/#define VM_MAX_READAHEAD\t512/" ./*/*/include/linux/mm.h &>/dev/null || true; #Lee Susman <lsusman@codeaurora.org>: Change the VM_MAX_READAHEAD value from the default 128KB to 512KB. This will allow the readahead window to grow to a maximum size of 512KB, which greatly benefits to sequential read throughput.
#fi;

if enter "device"; then
echo "Starting zram tweaks";
#Note: 14.1 uses zramstreams instead of max_comp_streams
#1GB (768MB)
sed -i 's/zramsize=.*/zramsize=75%,max_comp_streams=4/' asus/fugu/fstab.fugu &>/dev/null || true;
#1/2GB (768MB/1.5GB)
sed -i 's/zramsize=.*/zramsize=75%,max_comp_streams=4/' motorola/msm8916-common/rootdir/etc/fstab.qcom &>/dev/null || true;
#2GB (1GB)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=2/' htc/flounder/fstab.flounder &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' asus/flox/rootdir/etc/fstab.flox asus/debx/rootdir/etc/fstab.debx htc/msm8974-common/rootdir/etc/fstab.qcom lge/g2-common/rootdir/etc/fstab.g2 lge/mako/rootdir/etc/fstab.mako motorola/victara/rootdir/etc/fstab.qcom samsung/hlte-common/rootdir/etc/fstab.qcom samsung/klte-common/rootdir/etc/fstab.qcom &>/dev/null || true;
#2/3GB (1/1.5GB)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' lge/d850/rootdir/etc/fstab.g3 lge/d851/rootdir/etc/fstab.g3 lge/d852/rootdir/etc/fstab.g3 lge/d855/rootdir/etc/fstab.g3 motorola/athene/rootdir/etc/fstab.qcom samsung/apq8084-common/rootdir/etc/fstab.qcom &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=6/' lge/bullhead/fstab*.bullhead &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' asus/msm8916-common/rootdir/etc/fstab.qcom &>/dev/null || true;
#3GB (1.5GB)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' google/dragon/fstab.dragon* lge/f400/rootdir/etc/fstab.g3 ls990/rootdir/etc/fstab.g3 lge/vs985/rootdir/etc/fstab.g3 moto/shamu/rootdir/etc/fstab.shamu &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=6/' motorola/clark/rootdir/fstab.qcom &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' huawei/angler/fstab*.angler &>/dev/null || true;
#3/4GB (1.5/2GB)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' zuk/msm8996-common/rootdir/etc/fstab.qcom &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' oneplus/oneplus2/rootdir/etc/fstab.qcom &>/dev/null || true;
#4GB (2GB)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' google/marlin/fstab.common lge/msm8996-common/rootdir/etc/fstab.qcom motorola/griffin/rootdir/etc/fstab.qcom &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' essential/mata/rootdir/etc/fstab.mata google/bonito/fstab.hardware google/coral/fstab.hardware google/crosshatch/fstab*.hardware google/wahoo/fstab.hardware &>/dev/null || true;
#4GB/4GB+ (2GB/2GB+)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=4/' zte/axon7/rootdir/etc/fstab.qcom &>/dev/null || true;
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' sony/tama-common/rootdir/etc/fstab.qcom &>/dev/null || true;
#4GB+ (2GB+)
sed -i 's/zramsize=.*/zramsize=50%,max_comp_streams=8/' google/redbull/fstab.hardware google/sunfish/fstab.hardware oneplus/msm8998-common/rootdir/etc/fstab.qcom oneplus/sdm845-common/rootdir/etc/fstab.qcom xiaomi/sm6150-common/rootdir/etc/fstab*.qcom &>/dev/null || true;
echo "Finished zram tweaks";
fi;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Optimizing complete\e[0m";
