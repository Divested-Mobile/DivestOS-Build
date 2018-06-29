#!/bin/bash

#desc='/O=Divested Computing, Inc./CN=DivestOS/emailAddress=support@divestos.xyz';
desc='/O=Example/CN=ExampleOS/emailAddress=support@example.com';
type='rsa'; #Options: rsa, ec

"$DOS_BUILD_BASE"/development/tools/make_key extra "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key media "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key platform "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key releasekey "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key shared "$desc" "$type";
"$DOS_BUILD_BASE"/development/tools/make_key verity "$desc" "$type";

echo "Please copy created keys to your signing keys directory. Keep them safe!";
