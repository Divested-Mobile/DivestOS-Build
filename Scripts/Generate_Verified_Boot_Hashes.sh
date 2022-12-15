#!/bin/sh
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2022 Divested Computing Group
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

#grep "verity\.mk" Build/*/device/*/*/*.mk -l
VERITY_DEVICES=('Amber' 'angler' 'bullhead' 'cheeseburger' 'cheryl' 'discovery' 'dragon' 'dumpling' 'flounder' 'marlin' 'mata' 'oneplus3' 'pioneer' 'sailfish' 'shamu' 'voyager' 'z2_plus');
#grep "AVB_ENABLE" Build/*/device/*/*/*.mk -l
AVB_DEVICES=('akari' 'alioth' 'aura' 'aurora' 'avicii' 'barbet' 'beryllium' 'bluejay' 'blueline' 'bonito' 'bramble' 'cheetah' 'coral' 'crosshatch' 'davinci' 'enchilada' 'fajita' 'flame' 'FP3' 'FP4' 'guacamole' 'guacamoleb' 'hotdog' 'hotdogb' 'instantnoodle' 'instantnoodlep' 'kebab' 'lavender' 'lemonade' 'lemonadep' 'lmi' 'oriole' 'panther' 'pro1' 'raphael' 'raven' 'redfin' 'sargo' 'sunfish' 'taimen' 'vayu' 'walleye' 'xz2c');

#TODO: Make this a function?
echo "================================================================================";
echo "Verity Keys";
echo "================================================================================";
for f in */verifiedboot_relkeys.der.x509
do
	device=$(dirname $f);
	if [[ " ${VERITY_DEVICES[@]} " =~ " ${device} " ]]; then
		echo "Device: $device";
		sha1=$(cat $f | openssl dgst -sha1 -c | sed 's/(stdin)= //' | tr [a-z] [A-Z]);
		sha256=$(cat $f | openssl dgst -sha256 | sed 's/(stdin)= //' | tr [a-z] [A-Z]);
		#echo -e "\tSHA-1:"; #TODO: Figure out how this is actually calculated, perhaps lacks the actual certificate infomation due to mincrypt?
		#echo -e "\t\t$sha1";
		echo -e "\tSHA-256:";
		echo -e "\t\t${sha256:0:16}";
		echo -e "\t\t${sha256:16:16}";
		echo -e "\t\t${sha256:32:16}";
		echo -e "\t\t${sha256:48:16}";
	fi;
done
echo "================================================================================";
echo "AVB Keys";
echo "================================================================================";
for f in */avb_pkmd.bin
do
	device=$(dirname $f);
	if [[ " ${AVB_DEVICES[@]} " =~ " ${device} " ]]; then
		echo "Device: $device";
		sha256=$(cat $f | openssl dgst -sha256 | sed 's/(stdin)= //' | tr [a-z] [A-Z]);
		#echo -e "\tID:"; #Not really needed
		#echo -e "\t\t${sha256:0:8}";
		echo -e "\tSHA-256:";
		echo -e "\t\t${sha256:0:16}";
		echo -e "\t\t${sha256:16:16}";
		echo -e "\t\t${sha256:32:16}";
		echo -e "\t\t${sha256:48:16}";
	fi;
done
echo "================================================================================";
