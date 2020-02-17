#!/bin/bash

#Reference: https://grapheneos.org/build#generating-release-signing-keys

type='rsa'; #Options: rsa, ec

#source build/envsetup.sh && breakfast lineage_sailfish-user && make -j20 generate_verity_key;

cd "$DOS_SIGNING_KEYS/NEW";
mkdir $1; cd $1;

desc="/O=Divested Computing Group/CN=DivestOS for $1/emailAddress=support@divestos.org";

sed -i '/blank for none/,+1 d' "$DOS_BUILD_BASE"/development/tools/make_key;
sed -i 's/2048/4096/' "$DOS_BUILD_BASE"/development/tools/make_key;
"$DOS_BUILD_BASE"/development/tools/make_key extra "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key future-1 "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key future-2 "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key media "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key networkstack "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key platform "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key releasekey "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key shared "$desc" "$type";

sed -i 's/4096/2048/' "$DOS_BUILD_BASE"/development/tools/make_key;
"$DOS_BUILD_BASE"/development/tools/make_key verity "$desc" "$type";
"$DOS_BUILD_BASE"/out/host/linux-x86/bin/generate_verity_key -convert verity.x509.pem verity_key;
openssl x509 -outform der -in verity.x509.pem -out verifiedboot_relkeys.der.x509;

openssl genrsa -out avb.pem 4096;
"$DOS_BUILD_BASE"/external/avb/avbtool extract_public_key --key avb.pem --output avb_pkmd.bin;

cd "$DOS_BUILD_BASE";
