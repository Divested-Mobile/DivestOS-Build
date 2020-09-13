#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2020 Divested Computing Group
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

commentPatches() {
	file="$1";
	if [ -f $file ]; then
		shift;
		for var in "$@"
		do
			#escaped=$(printf "%q" "$var");
			#echo $escaped;
			sed -i $file -e '\|'$var'| s|^#*|#|';
		done
	fi;
}

commentPatches android_kernel_asus_fugu.sh "CVE-2015-8746/^4.2.2/0001.patch" "LVT-2017-0003/3.10/0001.patch";
commentPatches android_kernel_asus_grouper.sh "CVE-2017-15868";
commentPatches android_kernel_asus_msm8916.sh "CVE-2018-13913/ANY/0001.patch";
commentPatches android_kernel_asus_msm8953.sh "CVE-2017-13162/3.18/0001.patch";
commentPatches android_kernel_cyanogen_msm8916.sh "CVE-2018-13913/ANY/0001.patch";
commentPatches android_kernel_essential_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2017-13218/4.4/0026.patch" "CVE-2019-14047/ANY/0002.patch";
commentPatches android_kernel_fxtec_msm8998.sh "CVE-2019-11599" "CVE-2019-16746" "CVE-2019-18282" "CVE-2019-19319" "CVE-2019-ctnl-addr-leak" "CVE-2020-0429" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166/4.4/0002.patch";
commentPatches android_kernel_google_bonito.sh "CVE-2020-0067";
commentPatches android_kernel_google_dragon.sh "CVE-2015-4167/^3.19.1/0001.patch";
commentPatches android_kernel_google_crosshatch.sh "CVE-2020-0067";
commentPatches android_kernel_google_marlin.sh "0001-LinuxIncrementals/3.18/3.18.0098-0099.patch" "0006-Copperhead-Kernel_Hardening/3.18/0048.patch" "0006-Copperhead-Kernel_Hardening/3.18/0049.patch" "CVE-2017-13162/3.18/0001.patch";
commentPatches android_kernel_google_msm.sh "CVE-2017-11015/prima";
commentPatches android_kernel_google_msm-4.9.sh "CVE-2019-19319" "CVE-2020-0067" "CVE-2020-1749" "CVE-2020-8992";
commentPatches android_kernel_google_wahoo.sh "CVE-2019-14047/ANY/0002.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166/4.4/0002.patch";
commentPatches android_kernel_htc_flounder.sh "CVE-2018-9514/ANY/0001.patch";
commentPatches android_kernel_htc_msm8994.sh "CVE-2016-8394/ANY/0001.patch" "CVE-2017-13166";
commentPatches android_kernel_lge_msm8996.sh "CVE-2017-13162/3.18/0001.patch" "CVE-2018-17972" "CVE-2019-14070/ANY/0006.patch";
commentPatches android_kernel_motorola_msm8916.sh "0001-LinuxIncrementals/3.10/3.10.0050-0051.patch" "CVE-2018-9514/ANY/0001.patch";
commentPatches android_kernel_motorola_msm8974.sh "CVE-2016-5696" "CVE-2017-7373/3.4/0001.patch";
commentPatches android_kernel_motorola_msm8992.sh "CVE-2017-5551/3.10/0002.patch" "CVE-2017-14880/3.10/0001.patch" "CVE-2018-3585/3.10/0001.patch";
commentPatches android_kernel_motorola_msm8996.sh "0001-LinuxIncrementals/3.18/3.18.0098-0099.patch" "CVE-2017-13162/3.18/0001.patch" "CVE-2018-17972" "CVE-2019-14070/ANY/0006.patch";
commentPatches android_kernel_nextbit_msm8992.sh "CVE-2018-3585/3.10/0001.patch";
commentPatches android_kernel_oneplus_msm8994.sh "CVE-2018-3585/3.10/0001.patch";
commentPatches android_kernel_oneplus_msm8996.sh "CVE-2017-13162/3.18/0001.patch" "CVE-2019-14070/ANY/0006.patch";
commentPatches android_kernel_oneplus_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2019-11599";
commentPatches android_kernel_oneplus_sm8150.sh "CVE-2019-16746" "CVE-2019-19319" "CVE-2020-0067" "CVE-2020-8992";
commentPatches android_kernel_razer_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "CVE-2019-14070/ANY/0005.patch" "CVE-2020-16166/4.4/0002.patch";
commentPatches android_kernel_samsung_smdk4412.sh "CVE-2016-8463/ANY/0001.patch";
commentPatches android_kernel_samsung_universal8890.sh "CVE-2016-7917" "CVE-2018-1092" "CVE-2018-17972";
commentPatches android_kernel_samsung_universal9810.sh "CVE-2020-1749";
commentPatches android_kernel_yandex_sdm660.sh "CVE-2019-11599" "CVE-2019-14070/ANY/0005.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166/4.4/0002.patch";
commentPatches android_kernel_zte_msm8930.sh "CVE-2015-2922/^3.19.6/0001.patch" "CVE-2017-11015/prima";
commentPatches android_kernel_zuk_msm8996.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166/4.4/0002.patch";
