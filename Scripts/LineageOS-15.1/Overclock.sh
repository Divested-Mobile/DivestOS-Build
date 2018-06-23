#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing, Inc.
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

#Overclocks the CPU to increase performance
#Last verified: 2018-04-27

echo "Applying overclocks...";

enter "kernel/huawei/angler";
patch -p1 < "$patches/android_kernel_huawei_angler/0001-Overclock.patch";

enter "kernel/lge/g3";
patch -p1 < "$patches/android_kernel_lge_g3/0001-Overclock.patch"; #2.45Ghz -> 2.76Ghz	=+1.24Ghz
patch -p1 < "$patches/android_kernel_lge_g3/0002-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_g3/0003-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_g3/0004-Overclock.patch";

enter "kernel/lge/hammerhead";
patch -p1 < "$patches/android_kernel_lge_hammerhead/0001-Overclock.patch"; #2.26Ghz -> 2.95Ghz	=+2.76Ghz XXX: Untested!

enter "kernel/lge/mako";
patch -p1 < "$patches/android_kernel_lge_mako/0001-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_mako/0002-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_mako/0003-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_mako/0004-Overclock.patch";
patch -p1 < "$patches/android_kernel_lge_mako/0005-Overclock.patch";
echo "CONFIG_LOW_CPUCLOCKS=y" >> arch/arm/configs/lineageos_mako_defconfig; #384Mhz -> 81Mhz
echo "CONFIG_CPU_OVERCLOCK=y" >> arch/arm/configs/lineageos_mako_defconfig; #1.51Ghz -> 1.70Ghz  =+0.90Ghz
#echo "CPU_OVERCLOCK_ULTRA=y" >> arch/arm/configs/lineageos_mako_defconfig; #1.51Ghz -> 1.94Ghz =+1.72Ghz XXX: Causes excessive throttling

#enter "kernel/motorola/msm8916";
#patch -p1 < "$patches/android_kernel_motorola_msm8916/0001-Overclock.patch"; #1.36Ghz -> 1.88Ghz	=+ 2.07Ghz

enter "kernel/oppo/msm8974";
patch -p1 < "$patches/android_kernel_oppo_msm8974/0001-OverUnderClock-EXTREME.patch"; #300Mhz -> 268Mhz, 2.45Ghz -> 2.95Ghz	=+2.02Ghz XXX: Not 100% stable under intense workloads

cd "$base";
echo "Overclocks applied!";
