#!/bin/sh
VERITY_DEVICES=('Amber' 'angler' 'bullhead' 'cheeseburger' 'cheryl' 'dragon' 'dumpling' 'flounder' 'marlin' 'mata' 'oneplus3' 'sailfish' 'shamu' 'z2_plus');
AVB_DEVICES=('akari' 'alioth' 'aura' 'aurora' 'avicii' 'beryllium' 'blueline' 'bonito' 'bramble' 'coral' 'crosshatch' 'davinci' 'enchilada' 'fajita' 'flame' 'FP3' 'guacamole' 'guacamoleb' 'hotdog' 'hotdogb' 'lavender' 'lmi' 'pro1' 'raphael' 'redfin' 'sargo' 'sunfish' 'taimen' 'vayu' 'walleye' 'xz2c');

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
