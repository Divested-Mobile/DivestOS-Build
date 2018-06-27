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

enter "kernel/amazon/hdx-common";
patch -p1 < "$patches/android_kernel_amazon_hdx-common/0001-Overclock.patch"; #300MHz -> 268MHz, 2.26GHz -> 2.41GHz	=+0.60GHz
patch -p1 < "$patches/android_kernel_amazon_hdx-common/0002-Overclock.patch";
patch -p1 < "$patches/android_kernel_amazon_hdx-common/0003-Overclock.patch";
patch -p1 < "$patches/android_kernel_amazon_hdx-common/0004-Overclock.patch";

enter "kernel/asus/grouper";
patch -p1 < "$patches/android_kernel_asus_grouper/0001-Overclock.patch";
echo "CONFIG_TEGRA_CPU_OVERCLOCK=y" >> arch/arm/configs/grouper_defconfig; #1.30GHz -> 1.50GHz	=+0.80GHz
echo "CONFIG_TEGRA_CPU_OVERCLOCK_ULTIMATE" >> arch/arm/configs/grouper_defconfig; #1.30GHz -> 1.60GHz	=+1.20GHz
echo "CONFIG_TEGRA_GPU_OVERCLOCK=y" >> arch/arm/configs/grouper_defconfig; #416MHz 520MHz
echo "CONFIG_TEGRA_GAMING_FIX=y" >> arch/arm/configs/grouper_defconfig;

enter "kernel/lge/hammerhead";
patch -p1 < "$patches/android_kernel_lge_hammerhead/0001-Overclock.patch"; #2.26GHz -> 2.95GHz	=+2.76GHz XXX: Untested!

enter "kernel/motorola/msm8916";
patch -p1 < "$patches/android_kernel_motorola_msm8916/0001-Overclock.patch"; #1.36GHz -> 1.88GHz	=+ 2.07GHz

cd "$base";
echo "Overclocks applied!";
