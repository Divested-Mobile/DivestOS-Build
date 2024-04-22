#!/bin/sh
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2018-2023 Divested Computing Group
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

#Reference (MIT): https://grapheneos.org/build#generating-release-signing-keys

type='rsa'; #Options: rsa, ec

#source build/envsetup.sh && breakfast lineage_sailfish-user && make -j20 generate_verity_key otatools;
#source ../../Scripts/Generate_Signing_Keys.sh $device;

mkdir -p "$DOS_SIGNING_KEYS/NEW";
if [[ -d "$DOS_SIGNING_KEYS" ]]; then
	cd "$DOS_SIGNING_KEYS/NEW";
	mkdir $1; cd $1;

	desc="/O=Divested Computing Group/CN=DivestOS for $1/emailAddress=support@divestos.org";

	sed -i '/blank for none/,+1 d' "$DOS_BUILD_BASE"/development/tools/make_key;

	sed -i 's/4096/2048/' "$DOS_BUILD_BASE"/development/tools/make_key;
	"$DOS_BUILD_BASE"/development/tools/make_key releasekey "$desc" "$type";
	sed -i 's/2048/4096/' "$DOS_BUILD_BASE"/development/tools/make_key;
	"$DOS_BUILD_BASE"/development/tools/make_key extra "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key bluetooth "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key sdk_sandbox "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key future-1 "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key future-2 "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key future-3 "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key future-4 "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key media "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key networkstack "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key platform "$desc" "$type";
	"$DOS_BUILD_BASE"/development/tools/make_key shared "$desc" "$type";

	sed -i 's/4096/2048/' "$DOS_BUILD_BASE"/development/tools/make_key;
	"$DOS_BUILD_BASE"/development/tools/make_key verity "$desc" "$type";
	"$DOS_BUILD_BASE"/out/host/linux-x86/bin/generate_verity_key -convert verity.x509.pem verity_key;
	openssl x509 -outform der -in verity.x509.pem -out verifiedboot_relkeys.der.x509;

	openssl genrsa -out avb.pem 4096;
	"$DOS_BUILD_BASE"/external/avb/avbtool extract_public_key --key avb.pem --output avb_pkmd.bin;

	cd "$DOS_BUILD_BASE";
	echo "Be sure to move your new $1 keys into place (out of NEW)!";
else
	echo "Signing key directory does not exist!"
fi;
