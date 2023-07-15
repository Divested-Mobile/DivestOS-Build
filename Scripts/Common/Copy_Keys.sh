#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2020-2022 Divested Computing Group
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

copyKey() {
	if [[ -d "$DOS_SIGNING_KEYS/$1" ]] && [[ -d "$DOS_BUILD_BASE/$2" ]]; then
		if [[ -f "$DOS_SIGNING_KEYS/$1/verifiedboot_relkeys.der.x509" ]] && [[ -d "$DOS_BUILD_BASE/$2" ]]; then
			if cp "$DOS_SIGNING_KEYS/$1/verifiedboot_relkeys.der.x509" "$DOS_BUILD_BASE/$2/verifiedboot_$1_dos_relkeys.der.x509"; then
				echo -e "\e[0;32mCopied verifiedboot keys for $1 to $2\e[0m";
			else
				echo -e "\e[0;31mCould not copy verifiedboot keys for $1\e[0m";
			fi;
		fi;

		if [[ -f "$DOS_SIGNING_KEYS/$1/verity.x509.pem" ]] && [[ -d "$DOS_BUILD_BASE/$2/certs" ]]; then
			if cat "$DOS_SIGNING_KEYS/$1/verity.x509.pem" >> "$DOS_BUILD_BASE/$2/certs/verity.x509.pem"; then
				echo -e "\e[0;32mAppended verity keys for $1 to $2\e[0m";
			else
				echo -e "\e[0;31mCould not append verity keys for $1\e[0m";
			fi;
		fi;
	elif [[ ! -d "$DOS_SIGNING_KEYS/$1" ]] && [[ -d "$DOS_BUILD_BASE/$2" ]]; then
		echo -e "\e[0;31mNo keys available for $1 but kernel $2 exists!\e[0m";
	fi;
}

if [ -d "$DOS_SIGNING_KEYS" ]; then
	echo "Copying verity/avb public keys to kernels...";

	copyKey "akari" "kernel/sony/sdm845";
	copyKey "akatsuki" "kernel/sony/sdm845";
	copyKey "alioth" "kernel/xiaomi/sm8250";
	copyKey "Amber" "kernel/yandex/sdm660";
	copyKey "angler" "kernel/huawei/angler";
	copyKey "apollon" "kernel/xiaomi/sm8250";
	copyKey "aura" "kernel/razer/sdm845";
	copyKey "aurora" "kernel/sony/sdm845";
	copyKey "avicii" "kernel/oneplus/sm7250";
	copyKey "barbet" "kernel/google/redbull";
	copyKey "beryllium" "kernel/xiaomi/sdm845";
	copyKey "bluejay" "kernel/google/bluejay";
	copyKey "bluejay" "kernel/google/gs101/private/gs-google";
	copyKey "bluejay" "kernel/google/gs201/private/gs-google";
	copyKey "blueline" "kernel/google/crosshatch";
	copyKey "blueline" "kernel/google/msm-4.9";
	copyKey "bonito" "kernel/google/bonito";
	copyKey "bonito" "kernel/google/msm-4.9";
	copyKey "bramble" "kernel/google/redbull";
	copyKey "bullhead" "kernel/lge/bullhead";
	copyKey "cheeseburger" "kernel/oneplus/msm8998";
	copyKey "cheetah" "kernel/google/gs201/private/gs-google";
	copyKey "cheryl" "kernel/razer/msm8998";
	copyKey "coral" "kernel/google/coral";
	copyKey "crosshatch" "kernel/google/crosshatch";
	copyKey "crosshatch" "kernel/google/msm-4.9";
	copyKey "davinci" "kernel/xiaomi/sm6150";
	copyKey "dipper" "kernel/xiaomi/sdm845";
	copyKey "discovery" "kernel/sony/sdm660";
	copyKey "dragon" "kernel/google/dragon";
	copyKey "dumpling" "kernel/oneplus/msm8998";
	copyKey "enchilada" "kernel/oneplus/sdm845";
	copyKey "equuleus" "kernel/xiaomi/sdm845";
	copyKey "fajita" "kernel/oneplus/sdm845";
	copyKey "flame" "kernel/google/coral";
	copyKey "flounder" "kernel/htc/flounder";
	copyKey "FP3" "kernel/fairphone/sdm632";
	copyKey "FP4" "kernel/fairphone/sm7225";
	copyKey "griffin" "kernel/motorola/msm8996";
	copyKey "guacamoleb" "kernel/oneplus/sm8150";
	copyKey "guacamole" "kernel/oneplus/sm8150";
	copyKey "hotdogb" "kernel/oneplus/sm8150";
	copyKey "hotdog" "kernel/oneplus/sm8150";
	copyKey "instantnoodle" "kernel/oneplus/sm8250";
	copyKey "instantnoodlep" "kernel/oneplus/sm8250";
	copyKey "jasmine_sprout" "kernel/xiaomi/sdm660";
	copyKey "kebab" "kernel/oneplus/sm8250";
	copyKey "kirin" "kernel/sony/sdm660";
	copyKey "lavender" "kernel/xiaomi/sdm660";
	copyKey "lemonade" "kernel/oneplus/sm8350";
	copyKey "lemonadep" "kernel/oneplus/sm8350";
	copyKey "lemonades" "kernel/oneplus/sm8250";
	copyKey "lmi" "kernel/xiaomi/sm8250";
	copyKey "marlin" "kernel/google/marlin";
	copyKey "mata" "kernel/essential/msm8998";
	copyKey "mermaid" "kernel/sony/sdm660";
	copyKey "oneplus3" "kernel/oneplus/msm8996";
	copyKey "oriole" "kernel/google/gs101/private/gs-google";
	copyKey "oriole" "kernel/google/gs201/private/gs-google";
	copyKey "oriole" "kernel/google/raviole";
	copyKey "panther" "kernel/google/gs201/private/gs-google";
	copyKey "pioneer" "kernel/sony/sdm660";
	copyKey "platina" "kernel/xiaomi/sdm660";
	copyKey "polaris" "kernel/xiaomi/sdm845";
	copyKey "pro1" "kernel/fxtec/msm8998";
	copyKey "pro1x" "kernel/fxtec/sm6115";
	copyKey "raphael" "kernel/xiaomi/sm8150";
	copyKey "raven" "kernel/google/gs101/private/gs-google";
	copyKey "raven" "kernel/google/gs201/private/gs-google";
	copyKey "raven" "kernel/google/raviole";
	copyKey "redfin" "kernel/google/redbull";
	copyKey "sailfish" "kernel/google/marlin";
	copyKey "sargo" "kernel/google/bonito";
	copyKey "sargo" "kernel/google/msm-4.9";
	copyKey "shamu" "kernel/moto/shamu";
	copyKey "star2lte" "kernel/samsung/universal9810";
	copyKey "starlte" "kernel/samsung/universal9810";
	copyKey "sunfish" "kernel/google/sunfish";
	copyKey "taimen" "kernel/google/wahoo";
	copyKey "twolip" "kernel/xiaomi/sdm660";
	copyKey "ursa" "kernel/xiaomi/sdm845";
	copyKey "vayu" "kernel/xiaomi/sm8150";
	copyKey "voyager" "kernel/sony/sdm660";
	copyKey "walleye" "kernel/google/wahoo";
	copyKey "wayne" "kernel/xiaomi/sdm660";
	copyKey "whyred" "kernel/xiaomi/sdm660";
	copyKey "xz2c" "kernel/sony/sdm845";
	copyKey "z2_plus" "kernel/zuk/msm8996";
	copyKey "zenfone3" "kernel/asus/msm8953";

	echo -e "\e[0;32m[SCRIPT COMPLETE] Copied keys to kernels\e[0m";
else
	echo -e "\e[0;31mSigning keys unavailable, NOT copying public keys to kernels\e[0m";
fi;
