#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2020-2021 Divested Computing Group
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

commentPatches android_kernel_amazon_hdx-common.sh "CVE-2021-Misc2/3.4/0055.patch" "CVE-2021-Misc2/3.4/0056.patch";
commentPatches android_kernel_asus_fugu.sh "CVE-2014-2568" "CVE-2014-8559" "CVE-2015-8746" "CVE-2017-5551" "LVT-2017-0003/3.10/0001.patch";
commentPatches android_kernel_asus_grouper.sh "CVE-2017-15868" "CVE-2021-Misc2/3.4/0055.patch" "CVE-2021-Misc2/3.4/0056.patch";
commentPatches android_kernel_asus_msm8916.sh "CVE-2018-13913/ANY/0001.patch";
commentPatches android_kernel_asus_msm8953.sh "CVE-2017-13162/3.18/0001.patch";
commentPatches android_kernel_cyanogen_msm8916.sh "CVE-2018-13913/ANY/0001.patch" "CVE-2018-5897" "CVE-2018-9514" "CVE-2018-11266";
commentPatches android_kernel_cyanogen_msm8974.sh "CVE-2017-7373";
commentPatches android_kernel_essential_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2017-13218" "CVE-2019-14047/ANY/0002.patch";
commentPatches android_kernel_fairphone_msm8974.sh "CVE-2018-20169";
commentPatches android_kernel_fairphone_sdm632.sh "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2021-3347";
commentPatches android_kernel_fxtec_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2019-11599" "CVE-2019-16746" "CVE-2019-18282" "CVE-2019-19319" "CVE-2019-ctnl-addr-leak" "CVE-2020-0429" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166";
commentPatches android_kernel_google_bonito.sh "CVE-2020-0067";
commentPatches android_kernel_google_coral.sh "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992";
commentPatches android_kernel_google_dragon.sh "0006-AndroidHardening-Kernel_Hardening/3.18/0026.patch" "CVE-2015-4167" "CVE-2017-15951" "CVE-2016-1237" "CVE-2016-6198" "CVE-2017-7374" "CVE-2018-17972" "CVE-2019-2214";
commentPatches android_kernel_google_crosshatch.sh "CVE-2020-0067";
commentPatches android_kernel_google_marlin.sh "0001-LinuxIncrementals/3.18/3.18.0098-0099.patch" "0006-AndroidHardening-Kernel_Hardening/3.18/0048.patch" "0006-AndroidHardening-Kernel_Hardening/3.18/0049.patch" "CVE-2017-13162/3.18/0001.patch" "CVE-2017-14883" "CVE-2017-15951" "CVE-2018-17972" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_google_msm.sh "CVE-2017-11015/prima" "CVE-2021-Misc2/ANY/0031.patch";
commentPatches android_kernel_google_msm-4.9.sh "CVE-2019-19319" "CVE-2020-0067" "CVE-2020-1749" "CVE-2020-8992";
commentPatches android_kernel_google_redbull.sh "CVE-2018-5873" "CVE-2021-3444" "CVE-2021-3600";
commentPatches android_kernel_google_wahoo.sh "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2019-14047/ANY/0002.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166";
commentPatches android_kernel_google_yellowstone.sh "0001-LinuxIncrementals/3.10/3.10.0098-0099.patch" "CVE-2018-9514";
commentPatches android_kernel_huawei_angler.sh "CVE-2014-8559";
commentPatches android_kernel_htc_flounder.sh "CVE-2018-9514";
commentPatches android_kernel_htc_msm8960.sh "CVE-2018-10876" "CVE-2021-0695" "CVE-2021-Misc2/3.4/0055.patch" "CVE-2021-Misc2/3.4/0056.patch";
commentPatches android_kernel_htc_msm8974.sh "CVE-2016-8393";
commentPatches android_kernel_htc_msm8994.sh "CVE-2016-8394/ANY/0001.patch" "CVE-2017-13166" "CVE-2018-3585" "CVE-2018-9514";
commentPatches android_kernel_lge_bullhead.sh "CVE-2014-8559";
commentPatches android_kernel_lge_msm8992.sh "CVE-2018-5897" "CVE-2018-11266";
commentPatches android_kernel_lge_msm8996.sh "CVE-2016-6198" "CVE-2017-13162/3.18/0001.patch" "CVE-2017-15951" "CVE-2018-17972" "CVE-2019-2214" "CVE-2019-14070/ANY/0006.patch" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_moto_shamu.sh "CVE-2014-8559";
commentPatches android_kernel_motorola_msm8916.sh "0001-LinuxIncrementals/3.10/3.10.0050-0051.patch" "CVE-2014-8559" "CVE-2017-15817" "CVE-2018-9514";
commentPatches android_kernel_motorola_msm8974.sh "CVE-2016-5696" "CVE-2017-7373" "CVE-2017-17770/3.4/0002.patch" "CVE-2019-11599";
commentPatches android_kernel_motorola_msm8992.sh "CVE-2017-5551/3.10/0002.patch" "CVE-2017-14880/3.10/0001.patch" "CVE-2018-3585/3.10/0001.patch" "CVE-2019-2297/qcacld-2.0/0001.patch";
commentPatches android_kernel_motorola_msm8996.sh "0001-LinuxIncrementals/3.18/3.18.0098-0099.patch" "CVE-2017-8266" "CVE-2017-13162/3.18/0001.patch" "CVE-2017-15951" "CVE-2018-17972" "CVE-2019-2214" "CVE-2019-14070/ANY/0006.patch" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_nextbit_msm8992.sh "CVE-2018-3585/3.10/0001.patch" "CVE-2018-9514";
commentPatches android_kernel_oneplus_msm8994.sh "CVE-2018-3585/3.10/0001.patch" "CVE-2018-9514";
commentPatches android_kernel_oneplus_msm8996.sh "CVE-2017-13162/3.18/0001.patch" "CVE-2017-15951" "CVE-2017-16939" "CVE-2018-17972" "CVE-2019-2214" "CVE-2019-14070/ANY/0006.patch" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_oneplus_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2019-11599" "CVE-2019-19319" "CVE-2020-0305" "CVE-2020-8992" "CVE-2020-16166";
commentPatches android_kernel_oneplus_sm7250.sh "CVE-2018-5873" "CVE-2020-1749" "CVE-2021-3444" "CVE-2021-3600";
commentPatches android_kernel_oneplus_sm8150.sh "CVE-2019-16746" "CVE-2019-19319" "CVE-2020-0067" "CVE-2020-8992" "CVE-2020-24588/4.14/0018.patch";
commentPatches android_kernel_razer_msm8998.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "0008-Graphene-Kernel_Hardening/4.4/0019.patch" "CVE-2019-14070/ANY/0005.patch" "CVE-2020-16166";
commentPatches android_kernel_samsung_exynos5420.sh "CVE-2021-Misc2/3.4/0061.patch" "CVE-2021-Misc2/3.4/0062.patch";
commentPatches android_kernel_samsung_jf.sh "CVE-2019-11599";
commentPatches android_kernel_samsung_manta.sh "CVE-2021-Misc2/3.4/0055.patch" "CVE-2021-Misc2/3.4/0056.patch";
commentPatches android_kernel_samsung_msm8930-common.sh "CVE-2017-11015/prima" "CVE-2019-11599" "CVE-2021-Misc2/ANY/0031.patch";
commentPatches android_kernel_samsung_smdk4412.sh "CVE-2012-2127" "CVE-2016-8463/ANY/0001.patch";
commentPatches android_kernel_samsung_tuna.sh "CVE-2012-2127";
commentPatches android_kernel_samsung_universal8890.sh "CVE-2016-7917" "CVE-2018-1092" "CVE-2018-17972" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_samsung_universal9810.sh "CVE-2020-1749";
commentPatches android_kernel_xiaomi_sm8150.sh "CVE-2020-24588/4.14/0018.patch";
commentPatches android_kernel_xiaomi_sm8250.sh "CVE-2018-5873" "CVE-2020-1749" "CVE-2021-3444" "CVE-2021-3600";
commentPatches android_kernel_yandex_sdm660.sh "CVE-2019-11599" "CVE-2019-14070/ANY/0005.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-16166";
commentPatches android_kernel_zte_msm8930.sh "CVE-2015-2922" "CVE-2017-11015/prima";
commentPatches android_kernel_zte_msm8996.sh "0001-LinuxIncrementals/3.18/3.18.0098-0099.patch" "CVE-2017-13162" "CVE-2017-15951" "CVE-2017-16939" "CVE-2018-17972" "CVE-2019-2214" "CVE-2019-14070" "CVE-2019-16746" "CVE-2020-0427" "CVE-2020-14381" "CVE-2020-16166";
commentPatches android_kernel_zuk_msm8996.sh "0008-Graphene-Kernel_Hardening/4.4/0011.patch" "0008-Graphene-Kernel_Hardening/4.4/0012.patch" "0008-Graphene-Kernel_Hardening/4.4/0014.patch" "CVE-2019-19319" "CVE-2020-1749" "CVE-2020-8992" "CVE-2020-1616";
