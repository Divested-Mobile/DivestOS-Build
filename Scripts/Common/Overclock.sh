#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2018 Divested Computing Group
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

if enter "kernel/amazon/hdx-common"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_amazon_hdx-common/0001-Overclock.patch"; #300MHz -> 268MHz, 2.26GHz -> 2.41GHz
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_amazon_hdx-common/0002-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_amazon_hdx-common/0003-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_amazon_hdx-common/0004-Overclock.patch";
fi;

if enter "kernel/asus/grouper-DISABLED"; then #XXX: Disabled
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_asus_grouper/0001-Overclock.patch";
echo "CONFIG_TEGRA_CPU_OVERCLOCK=y" >> arch/arm/configs/grouper_defconfig; #1.30GHz -> 1.50GHz
echo "CONFIG_TEGRA_CPU_OVERCLOCK_ULTIMATE=y" >> arch/arm/configs/grouper_defconfig; #1.30GHz -> 1.60GHz
echo "CONFIG_TEGRA_GPU_OVERCLOCK=y" >> arch/arm/configs/grouper_defconfig; #416MHz -> 520MHz
echo "CONFIG_TEGRA_GAMING_FIX=y" >> arch/arm/configs/grouper_defconfig;
fi;

if enter "kernel/huawei/angler"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_huawei_angler/0001-Overclock.patch";
fi;

if enter "kernel/lge/g3"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_g3/0001-Overclock.patch"; #2.45GHz -> 2.76GHz
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_g3/0002-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_g3/0003-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_g3/0004-Overclock.patch";
fi;

if enter "kernel/lge/hammerhead"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_hammerhead/0001-Overclock.patch"; #2.26GHz -> 2.95GHz
fi;

if enter "kernel/lge/mako"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_mako/0001-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_mako/0002-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_mako/0003-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_mako/0004-Overclock.patch";
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_lge_mako/0005-Overclock.patch";
echo "CONFIG_LOW_CPUCLOCKS=y" >> arch/arm/configs/lineageos_mako_defconfig; #384MHz -> 81MHz
echo "CONFIG_CPU_OVERCLOCK=y" >> arch/arm/configs/lineageos_mako_defconfig; #1.51GHz -> 1.70GHz
#echo "CONFIG_CPU_OVERCLOCK_ULTRA=y" >> arch/arm/configs/lineageos_mako_defconfig; #1.51GHz -> 1.94GHz XXX: Throttles
if enter "device/lge/mako"; then
	sed -i 's/scaling_min_freq 384000/scaling_min_freq 81000/' rootdir/etc/init.mako.power.rc;
	#sed -i 's/scaling_max_freq 1512000/scaling_max_freq 1728000/' rootdir/etc/init.mako.power.rc;
	#sed -i 's/NORMAL_FREQ "1512000"/NORMAL_FREQ "1728000"/' power/power_mako.c;
	#sed -i 's/scaling_max_freq 1512000/scaling_max_freq 1944000/' rootdir/etc/init.mako.power.rc;
	#sed -i 's/NORMAL_FREQ "1512000"/NORMAL_FREQ "1944000"/' power/power_mako.c;
fi;
fi;

if enter "kernel/motorola/msm8916"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_motorola_msm8916/0001-Overclock.patch"; #1.36GHz -> 1.88GHz
fi;

if enter "kernel/oneplus/msm8974"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_oppo_msm8974/0001-OverUnderClock-EXTREME.patch"; #300MHz -> 268MHz, 2.45GHz -> 2.95GHz
fi;

if enter "kernel/oppo/msm8974"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_oppo_msm8974/0001-OverUnderClock-EXTREME.patch"; #300MHz -> 268MHz, 2.45GHz -> 2.95GHz
fi;

if enter "kernel/zte/msm8930-DISABLED"; then
patch -p1 < "$DOS_PATCHES_OVERCLOCKS/android_kernel_zte_msm8930/0001-Overclock.patch";
fi;

cd "$DOS_BUILD_BASE";
echo "Overclocks applied!";
