import sys

apexes = open(sys.argv[1], "r");
for line in apexes:
	print('--extra_apks ' + line.strip() + '.apex="$KEY_DIR/releasekey" \\');
	print('--extra_apex_payload_key ' + line.strip() + '.apex="$KEY_DIR/avb.pem" \\');
