#export desc='/O=Divested Computing, Inc./CN=DivestOS/emailAddress=support@divestos.xyz';
export desc='/O=Example/CN=ExampleOS/emailAddress=support@example.com';
export type='rsa'; #Options: rsa, ec

$base/development/tools/make_key extra "$desc" "$type";
$base/development/tools/make_key media "$desc" "$type";
$base/development/tools/make_key platform "$desc" "$type";
$base/development/tools/make_key releasekey "$desc" "$type";
$base/development/tools/make_key shared "$desc" "$type";
$base/development/tools/make_key verity "$desc" "$type";

echo "Please copy created keys to your signing keys directory. Keep them safe!";
