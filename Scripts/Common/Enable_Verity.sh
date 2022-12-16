#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2021-2022 Divested Computing Group
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
set -euo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

cd "$DOS_BUILD_BASE";
echo "Enabling verity...";

enableVerity() {
	if [ -d "$DOS_BUILD_BASE/$1" ]; then
		cd "$DOS_BUILD_BASE/$1";
		#TODO: skip if recoveryonly is set?
		sed -i '/\/system/{/verify/!s|wait|wait,verify|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		cd "$DOS_BUILD_BASE";
		echo "Enabled verity for $1";
	fi;
}
export -f enableVerity;

enableAVB() {
	if [ -d "$DOS_BUILD_BASE/$1" ]; then
		cd "$DOS_BUILD_BASE/$1";
		awk -i inplace '!/AVB_MAKE_VBMETA_IMAGE_ARGS \+= --set_hashtree_disabled_flag/' *.mk &>/dev/null || true;
		if [[ "$1" == *"xiaomi"* ]]; then #XXX: broken
			sed -i 's/AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/' *.mk &>/dev/null || true;
			echo "Setting PERMISSIVE AVB for $1";
		elif [[ "$DOS_VERSION" == "LineageOS-18.1" ]] && [[ "$1" == *"oneplus/sdm845-common"* ]]; then #XXX: uses stock /vendor
			sed -i 's/AVB_MAKE_VBMETA_IMAGE_ARGS += --flag 2/AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/' *.mk &>/dev/null || true;
			sed -i 's/AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/' *.mk &>/dev/null || true;
			echo "Setting PERMISSIVE AVB for $1";
		else
			awk -i inplace '!/AVB_MAKE_VBMETA_IMAGE_ARGS \+= --flag/' *.mk &>/dev/null || true;
			echo "Setting ENFORCING AVB for $1";
		fi;
		#Disable chaining
		awk -i inplace '!/BOARD_AVB_VBMETA_SYSTEM/' *.mk &>/dev/null || true;
		awk -i inplace '!/BOARD_AVB_VBMETA_VENDOR/' *.mk &>/dev/null || true;
		awk -i inplace '!/BOARD_AVB_BOOT/' *.mk &>/dev/null || true;
		#awk -i inplace '!/BOARD_AVB_RECOVERY/' *.mk &>/dev/null || true; #Must be defined for if non-A/B is supported.
		awk -i inplace '!/vbmeta_system \\/' *.mk &>/dev/null || true;
		awk -i inplace '!/vbmeta_vendor \\/' *.mk &>/dev/null || true;
		sed -i 's/vbmeta_system//' *.mk &>/dev/null || true;
		sed -i 's/vbmeta_vendor//' *.mk &>/dev/null || true;
		sed -i '/\/system /{s|avb=vbmeta_system|avb=vbmeta|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/system_ext/{s|avb=vbmeta_system|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/system_ext/{s|avb=vbmeta|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/vendor/{s|avb=vbmeta_system|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/vendor/{s|avb=vbmeta_vendor|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/vendor/{s|avb=vbmeta|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		#sed -i '/\/pvmfw/{s|avb=pvmfw|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		#sed -i '/\/boot/{s|avb=boot|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		#sed -i '/\/init_boot/{s|avb=init_boot|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/product/{s|avb=vbmeta_system|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		sed -i '/\/product/{s|avb=vbmeta|avb|}' *fstab* */*fstab* */*/*fstab* &>/dev/null || true;
		#TODO: remove avb_keys=.*?
		echo "Enabled AVB for $1";
		cd "$DOS_BUILD_BASE";
	fi;
}
export -f enableAVB;

#Device Changes
enableVerity "device/essential/mata";
#enableVerity "device/google/dragon"; #XXX: non-standard
enableVerity "device/google/marlin";
enableVerity "device/google/sailfish";
#enableVerity "device/htc/flounder"; #XXX: no boot
#enableVerity "device/htc/flounder_lte";
enableVerity "device/huawei/angler";
enableVerity "device/lge/bullhead";
enableVerity "device/moto/shamu";
enableVerity "device/oneplus/cheeseburger";
enableVerity "device/oneplus/dumpling";
enableVerity "device/oneplus/msm8998-common";
enableVerity "device/oneplus/oneplus3";
enableVerity "device/razer/cheryl";
#enableVerity "device/sony/discovery";
#enableVerity "device/sony/nile-common";
#enableVerity "device/sony/pioneer";
#enableVerity "device/sony/voyager";
enableVerity "device/yandex/Amber";
enableVerity "device/zuk/msm8996-common";
enableVerity "device/zuk/z2_plus";

enableAVB "device/fairphone/FP3";
enableAVB "device/fairphone/FP4";
enableAVB "device/fxtec/pro1";
enableAVB "device/google/barbet";
enableAVB "device/google/bluejay";
enableAVB "device/google/blueline";
enableAVB "device/google/bonito";
enableAVB "device/google/bramble";
enableAVB "device/google/cheetah";
enableAVB "device/google/coral";
enableAVB "device/google/crosshatch";
enableAVB "device/google/flame";
enableAVB "device/google/gs101";
enableAVB "device/google/gs201";
enableAVB "device/google/muskie";
enableAVB "device/google/oriole";
enableAVB "device/google/pantah";
enableAVB "device/google/panther";
enableAVB "device/google/raven";
enableAVB "device/google/raviole";
enableAVB "device/google/redbull";
enableAVB "device/google/redfin";
enableAVB "device/google/sargo";
enableAVB "device/google/sunfish";
enableAVB "device/google/taimen";
enableAVB "device/google/wahoo";
enableAVB "device/google/walleye";
enableAVB "device/oneplus/avicii";
enableAVB "device/oneplus/enchilada";
enableAVB "device/oneplus/fajita";
enableAVB "device/oneplus/guacamole";
enableAVB "device/oneplus/guacamoleb";
enableAVB "device/oneplus/hotdog";
enableAVB "device/oneplus/hotdogb";
enableAVB "device/oneplus/instantnoodle";
enableAVB "device/oneplus/instantnoodlep";
enableAVB "device/oneplus/kebab";
enableAVB "device/oneplus/lemonade";
enableAVB "device/oneplus/lemonadep";
enableAVB "device/oneplus/sdm845-common";
enableAVB "device/oneplus/sm8150-common";
enableAVB "device/oneplus/sm8250-common";
enableAVB "device/oneplus/sm8350-common";
enableAVB "device/razer/aura";
enableAVB "device/sony/akari";
enableAVB "device/sony/aurora";
enableAVB "device/sony/tama-common";
enableAVB "device/sony/xz2c";
enableAVB "device/xiaomi/alioth";
enableAVB "device/xiaomi/beryllium";
enableAVB "device/xiaomi/davinci";
enableAVB "device/xiaomi/lavender";
enableAVB "device/xiaomi/lmi";
enableAVB "device/xiaomi/raphael";
enableAVB "device/xiaomi/sdm660-common";
enableAVB "device/xiaomi/sdm845-common";
enableAVB "device/xiaomi/sm6150-common";
enableAVB "device/xiaomi/sm8150-common";
enableAVB "device/xiaomi/sm8250-common";
enableAVB "device/xiaomi/vayu";

#Kernel Changes
sed -i 's/slotselect/slotselect,verify/' kernel/essential/msm8998/arch/arm64/boot/dts/essential/msm8998-mata-lineage.dtsi &>/dev/null || true; #/vendor
#sed -i 's/wait/wait,verify/g' kernel/htc/flounder/arch/arm64/boot/dts/tegra132.dtsi &>/dev/null || true; #/system #XXX: no boot
sed -i 's/wait/wait,verify/g' kernel/moto/shamu/arch/arm/boot/dts/qcom/apq8084.dtsi &>/dev/null || true; #/system
sed -i 's/wait/wait,verify/g' kernel/oneplus/msm8996/arch/arm/boot/dts/qcom/15801/msm8996-mtp.dtsi &>/dev/null || true; #/system
sed -i 's/wait/wait,verify/g' kernel/oneplus/msm8998/arch/arm/boot/dts/qcom/cheeseburger.dtsi &>/dev/null || true; #/system and /vendor
sed -i 's/wait/wait,verify/g' kernel/oneplus/msm8998/arch/arm/boot/dts/qcom/dumpling.dtsi &>/dev/null || true; #/system and /vendor
sed -i 's/wait/wait,verify/g' kernel/zuk/msm8996/arch/arm/boot/dts/qcom/zuk/common.dtsi &>/dev/null || true; #/system and /vendor
#not used
#sed -i 's/wait/wait,verify/g' kernel/cyanogen/msm8916/arch/arm/boot/dts/qcom/msm8916.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/cyanogen/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/fairphone/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/google/yellowstone/arm/boot/dts/tegra124-yellowstone.dts &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/htc/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/htc/msm8994/arch/arm/boot/dts/qcom/msm8994.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/lge/g3/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/lge/hammerhead/arm/boot/dts/msm8974-hammerhead/msm8974-hammerhead.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/lge/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/lge/msm8996/arch/arm/boot/dts/qcom/msm8996.dtsi &>/dev/null || true; #/system and /vendor
#sed -i 's/wait/wait,verify/g' kernel/motorola/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/nextbit/ether/arch/arm/boot/dts/qcom/msm8992.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/oneplus/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/oneplus/msm8994/arch/arm/boot/dts/qcom/msm8994.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/oppo/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/samsung/msm8974/arch/arm/boot/dts/msm8974.dtsi &>/dev/null || true; #/system
#sed -i 's/wait/wait,verify/g' kernel/xiaomi/msm8937/arm64/boot/dts/xiaomi/common/msm8937.dtsi &>/dev/null || true; #/system and /vendor
#sed -i 's/wait/wait,verify/g' kernel/zte/msm8996/arch/arm/boot/dts/qcom/msm8996.dtsi &>/dev/null || true; #/system and /vendor
#sed -i 's/wait/wait,verify/g' kernel/zte/msm8996/arch/arm/boot/dts/qcom/zte-msm8996-v3-pmi8996-ailsa_ii.dtsi &>/dev/null || true; #/system and /vendor


sed -i 's/^\treturn VERITY_STATE_DISABLE;//' kernel/*/*/drivers/md/dm-android-verity.c &>/dev/null || true;
#sed -i 's/#if 0/#if 1/' kernel/*/*/drivers/power/reset/msm-poweroff.c &>/dev/null || true; #TODO: needs refinement

#Ensure OEM unlocking toggle is always available
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/essential/mata/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/fairphone/FP3/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/fairphone/FP4/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/fxtec/pro1/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/bluejay/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/bonito/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/coral/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/crosshatch/product.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/crosshatch/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/dragon/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/marlin/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/pantah/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/raviole/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/redbull/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/sunfish/vendor.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/wahoo/system.prop &>/dev/null || true;
#sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/google/yellowstone/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/huawei/angler/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/lge/bullhead/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/moto/shamu/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/nextbit/ether/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/avicii/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/msm8998-common/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/oneplus2/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/oneplus3/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/sdm845-common/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/sm8150-common/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/sm8250-common/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/oneplus/sm8350-common/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/razer/aura/system.prop &>/dev/null || true;
sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/razer/cheryl/system.prop &>/dev/null || true;
#sed -zi '/ro.oem_unlock_supported=1/!s/$/\nro.oem_unlock_supported=1/' device/yandex/Amber/system.prop &>/dev/null || true;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Verity enablement complete\e[0m";
