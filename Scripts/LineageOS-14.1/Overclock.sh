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

#Overclocks the CPU to increase performance
#Last verified: 2018-04-27

echo "Applying overclocks...";

enter "kernel/amazon/hdx-common";
patch -p1 < $patches"android_kernel_amazon_hdx-common/0001-Overclock.patch"; #300Mhz -> 268Mhz, 2.26Ghz -> 2.41Ghz	=+0.60Ghz
patch -p1 < $patches"android_kernel_amazon_hdx-common/0002-Overclock.patch";
patch -p1 < $patches"android_kernel_amazon_hdx-common/0003-Overclock.patch";
patch -p1 < $patches"android_kernel_amazon_hdx-common/0004-Overclock.patch";

enter "kernel/lge/hammerhead";
patch -p1 < $patches"android_kernel_lge_hammerhead/0001-Overclock.patch"; #2.26Ghz -> 2.95Ghz	=+2.76Ghz XXX: Untested!

enter "kernel/lge/msm8992";
patch -p1 < $patches"android_kernel_common_msm8992/0001-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0003-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0004-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0005-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0006-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0007-Overclock.patch";

enter "kernel/motorola/msm8916";
patch -p1 < $patches"android_kernel_motorola_msm8916/0001-Overclock.patch"; #1.36Ghz -> 1.88Ghz	=+ 2.07Ghz

enter "kernel/motorola/msm8992";
patch -p1 < $patches"android_kernel_common_msm8992/0001-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0003-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0004-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0005-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0006-Overclock.patch";
patch -p1 < $patches"android_kernel_common_msm8992/0007-Overclock.patch";

cd $base;
echo "Overclocks applied!";
