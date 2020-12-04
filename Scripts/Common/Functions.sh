#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2020 Divested Computing Group
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

if [ "$DOS_NON_COMMERCIAL_USE_PATCHES" = true ]; then
	echo -e "\e[0;33mWARNING: YOU HAVE ENABLED PATCHES THAT WHILE ARE OPEN SOURCE ARE ALSO ENCUMBERED BY RESTRICTIVE LICENSES\e[0m";
	echo -e "\e[0;33mPLEASE SEE THE 'LICENSES' FILE AT THE ROOT OF THIS REPOSITORY FOR MORE INFORMATION\e[0m";
	echo -e "\e[0;33mDISABLE THEM BY SETTING 'NON_COMMERCIAL_USE_PATCHES' TO 'false' IN 'Scripts/init.sh'\e[0m";
	sleep 15;
fi;

startPatcher() {
	java -jar "$DOS_BINARY_PATCHER" patch workspace "$DOS_BUILD_BASE" "$DOS_WORKSPACE_ROOT""Patches/Linux/" "$DOS_SCRIPTS_CVES" $1;
}
export -f startPatcher;

enter() {
	echo "================================================================================================"
	local dir="$1";
	local dirReal="$DOS_BUILD_BASE$dir";
	if [ -d "$dirReal" ]; then
		cd "$dirReal";
		echo -e "\e[0;32m[ENTERING] $dir\e[0m";
		return 0;
	else
		echo -e "\e[0;31m[ENTERING FAILED] $dir\e[0m";
		return 1;
	fi;
}
export -f enter;

enterAndClear() {
	if enter "$1"; then gitReset; else return 1; fi;
}
export -f enterAndClear;

gitReset() {
	git add -A && git reset --hard;
}
export -f gitReset;

gpgVerifyDirectory() {
	if [ -r "$HOME/.gnupg" ]; then
		for sig in $1/*.asc; do
			gpg --verify $sig &>/dev/null;
			if [ "$?" -eq "0" ]; then
				echo -e "\e[0;32mGPG Verified Successfully: $sig\e[0m";
			else
				echo -e "\e[0;31mWARNING: GPG Verification Failed: $sig\e[0m";
				sleep 60;
			fi;
		done;
	else
		echo -e "\e[0;33mWARNING: ~/.gnupg is unavailable, GPG verification of $1 will not be performed!\e[0m";
	fi;
}
export -f gpgVerifyDirectory;

scanForMalware() {
	if [ -x /usr/bin/clamscan ] && [ -r /var/lib/clamav/main.c*d ]; then
		echo -e "\e[0;32mStarting a malware scan...\e[0m";
		local excludes="--exclude-dir=\".git\" --exclude-dir=\".repo\"";
		local scanQueue="$2";
		if [ "$1" = true ]; then
			if [ "$DOS_MALWARE_SCAN_SETTING" != "quick" ] || [ "$DOS_MALWARE_SCAN_SETTING" = "extra" ]; then
				scanQueue=$scanQueue" $DOS_BUILD_BASE/frameworks $DOS_BUILD_BASE/vendor";
			fi;
			if [ "$DOS_MALWARE_SCAN_SETTING" = "slow" ]; then
				scanQueue=$scanQueue"$DOS_BUILD_BASE/external $DOS_BUILD_BASE/prebuilts $DOS_BUILD_BASE/toolchain $DOS_BUILD_BASE/tools";
			fi;
			if [ "$DOS_MALWARE_SCAN_SETTING" = "full" ]; then
				scanQueue="$DOS_BUILD_BASE";
			fi;
		fi;
		du -hsc $scanQueue;
		/usr/bin/clamscan --recursive --detect-pua --infected --allmatch $excludes $scanQueue;
		local clamscanExit="$?";
		if [ "$clamscanExit" -eq "1" ]; then
			echo -e "\e[0;31m----------------------------------------------------------------\e[0m";
			echo -e "\e[0;31mWARNING: MALWARE WAS FOUND! PLEASE INVESTIGATE!\e[0m";
			echo -e "\e[0;31m----------------------------------------------------------------\e[0m";
			echo -e "\e[0;33mFalse positives such as the following are probably OK\e[0m";
			echo -e "\e[0;33mPUAs: Ewind, Mobidash\e[0m";
			echo -e "\e[0;31m----------------------------------------------------------------\e[0m";
			sleep 60;
		fi;
		if [ "$clamscanExit" -eq "0" ]; then
			echo -e "\e[0;32mNo malware found\e[0m";
		fi;
		if [ "$clamscanExit" -eq "2" ]; then
			echo -e "\e[0;33m----------------------------------------------------------------\e[0m";
			echo -e "\e[0;33mWARNING: AN ERROR OCCURED. PLEASE INVESTIGATE!\e[0m";
			echo -e "\e[0;33m----------------------------------------------------------------\e[0m";
			sleep 60;
		fi;
	else
		echo -e "\e[0;33mWARNING: clamscan is unavailable, a malware scan will not be performed!\e[0m";
	fi;
}
export -f scanForMalware;

generateBootAnimationMask() {
	local text=$1;
	local font=$2
	local output=$3;
	convert -background black -fill transparent -font "$font" -gravity center -size 512x128 label:"$text" "$output";
}
export -f generateBootAnimationMask;

generateBootAnimationShine() {
	local color=$1;
	local style=$2;
	local output=$3;
	#The colors need to be symmetrical in order to make the animation smooth and not have any noticble lines
	convert -size 1024x128 -define gradient:angle=90 "$style":"$color" \( +clone -flop \) +append "$output";
}
export -f generateBootAnimationShine;

audit2allowCurrent() {
	adb logcat -b all -d | audit2allow -p "$OUT"/root/sepolicy;
}
export -f audit2allowCurrent;

audit2allowADB() {
	adb pull /sys/fs/selinux/policy;
	adb logcat -b all -d | audit2allow -p policy;
}
export -f audit2allowADB;

processRelease() {
	#Partial Credit: GrapheneOS
	#https://github.com/GrapheneOS/script/blob/10/release.sh
	local DEVICE="$1";
	local BLOCK="$2";
	local VERITY="$3";

	local DATE=$(date -u '+%Y%m%d')
	local KEY_DIR="$DOS_SIGNING_KEYS/$DEVICE";
	local VERSION=$(echo $DOS_VERSION | cut -f2 -d "-");
	local PREFIX="$DOS_BRANDING_ZIP_PREFIX-$VERSION-$DATE-dos-$DEVICE";
	local ARCHIVE="$DOS_BUILDS/$DOS_VERSION/release_keys/";
	local OUT_DIR="$DOS_BUILD_BASE/out/target/product/$DEVICE/";

	echo -e "\e[0;32mProcessing release for $DEVICE\e[0m";

	#Arguments
	if [ "$BLOCK" != false ]; then
		local BLOCK_SWITCHES="--block";
	fi;
	if [[ "$VERITY" == "verity" ]]; then
		local VERITY_SWITCHES=(--replace_verity_public_key "$KEY_DIR/verity_key.pub" \
			--replace_verity_private_key "$KEY_DIR/verity" \
			--replace_verity_keyid "$KEY_DIR/verity.x509.pem");
		echo -e "\e[0;32m\t+ Verified Boot 1.0\e[0m";
	elif [[ "$VERITY" == "avb" ]]; then
		#TODO: Verify if both SHA512 and RSA4096 is always supported
		local VERITY_SWITCHES=(--avb_vbmeta_key "$KEY_DIR/avb.pem" \
			--avb_vbmeta_algorithm SHA512_RSA4096 \
			--avb_system_key "$KEY_DIR/avb.pem" \
			--avb_system_algorithm SHA512_RSA4096);
		local AVB_PKMD="$KEY_DIR/avb_pkmd.bin";
		echo -e "\e[0;32m\t+ Verified Boot 2.0\e[0m";
	fi;

	#Malware Scan
	if [ "$DOS_MALWARE_SCAN_BEFORE_SIGN" = true ]; then
		echo -e "\e[0;32mScanning files for malware before signing\e[0m";
		scanForMalware false "$OUT_DIR/obj/PACKAGING/target_files_intermediates/*$DEVICE-target_files-*.zip";
	fi;

	#Target Files
	echo -e "\e[0;32mSigning target files\e[0m";
	build/tools/releasetools/sign_target_files_apks -o -d "$KEY_DIR" \
		"${VERITY_SWITCHES[@]}" \
		$OUT_DIR/obj/PACKAGING/target_files_intermediates/*$DEVICE-target_files-*.zip \
		$OUT_DIR/$PREFIX-target_files.zip;
	sha512sum $OUT_DIR/$PREFIX-target_files.zip > $OUT_DIR/$PREFIX-target_files.zip.sha512sum;
	local INCREMENTAL_ID=$(grep "ro.build.version.incremental" $OUT_DIR/system/build.prop | cut -f2 -d "=" | sed 's/\.//g');
	echo $INCREMENTAL_ID > $OUT_DIR/$PREFIX-target_files.zip.id;

	#Image
	if [ ! -f $OUT_DIR/recovery.img ]; then
		echo -e "\e[0;32mCreating fastboot image\e[0m";
		build/tools/releasetools/img_from_target_files $OUT_DIR/$PREFIX-target_files.zip \
			$OUT_DIR/$PREFIX-fastboot.zip || exit 1;
		sha512sum $OUT_DIR/$PREFIX-fastboot.zip > $OUT_DIR/$PREFIX-fastboot.zip.sha512sum;
	fi

	#OTA
	echo -e "\e[0;32mCreating OTA\e[0m";
	build/tools/releasetools/ota_from_target_files $BLOCK_SWITCHES -k "$KEY_DIR/releasekey" \
		$OUT_DIR/$PREFIX-target_files.zip  \
		$OUT_DIR/$PREFIX-ota.zip;
	md5sum $OUT_DIR/$PREFIX-ota.zip > $OUT_DIR/$PREFIX-ota.zip.md5sum;
	sha512sum $OUT_DIR/$PREFIX-ota.zip > $OUT_DIR/$PREFIX-ota.zip.sha512sum;

	#Deltas
	if [ "$DOS_GENERATE_DELTAS" = true ]; then
		for LAST_TARGET_FILES in $ARCHIVE/target_files/$DOS_BRANDING_ZIP_PREFIX-$VERSION-*-dos-$DEVICE-target_files.zip; do
			if [[ -f "$LAST_TARGET_FILES.id" ]]; then
				local LAST_INCREMENTAL_ID=$(cat "$LAST_TARGET_FILES.id");
				echo -e "\e[0;32mGenerating incremental OTA against $LAST_INCREMENTAL_ID\e[0m";
				#TODO: Verify GPG signature and checksum of target-files first!
				build/tools/releasetools/ota_from_target_files $BLOCK_SWITCHES -t 8 -k "$KEY_DIR/releasekey" -i \
					"$LAST_TARGET_FILES" \
					$OUT_DIR/$PREFIX-target_files.zip \
					$OUT_DIR/$PREFIX-incremental_$LAST_INCREMENTAL_ID.zip;
				sha512sum $OUT_DIR/$PREFIX-incremental_$LAST_INCREMENTAL_ID.zip > $OUT_DIR/$PREFIX-incremental_$LAST_INCREMENTAL_ID.zip.sha512sum;
			fi;
		done;
	fi;

	#Extract signed recovery
	unzip -l $OUT_DIR/$PREFIX-target_files.zip | grep -q recovery.img;
	local hasRecoveryImg=$?;
	if [ "$hasRecoveryImg" == "0" ]; then
		echo -e "\e[0;32mExtracting signed recovery.img\e[0m";
		mkdir $OUT_DIR/rec_tmp;
		unzip $OUT_DIR/$PREFIX-target_files.zip IMAGES/recovery.img -d $OUT_DIR/rec_tmp;
		mv $OUT_DIR/rec_tmp/IMAGES/recovery.img $OUT_DIR/$PREFIX-recovery.img;
		sha512sum $OUT_DIR/$PREFIX-recovery.img > $OUT_DIR/$PREFIX-recovery.img.sha512sum;
	#else
	#	echo -e "\e[0;32mExtracting signed boot.img\e[0m";
	#	mkdir $OUT_DIR/rec_tmp;
	#	unzip $OUT_DIR/$PREFIX-target_files.zip IMAGES/boot.img -d $OUT_DIR/rec_tmp;
	#	mv $OUT_DIR/rec_tmp/IMAGES/boot.img $OUT_DIR/$PREFIX-boot.img;
	#	sha512sum $OUT_DIR/$PREFIX-boot.img > $OUT_DIR/$PREFIX-boot.img.sha512sum;
	fi;

	#File name fixes
	sed -i "s|$OUT_DIR/||" $OUT_DIR/*.md5sum $OUT_DIR/*.sha512sum;
	sed -i 's/-ota\././' $OUT_DIR/*.md5sum $OUT_DIR/*.sha512sum;
	sed -i 's/-incremental_/-/' $OUT_DIR/*.md5sum $OUT_DIR/*.sha512sum;

	#GPG signing
	if [ "$DOS_GPG_SIGNING" = true ]; then
		for checksum in $OUT_DIR/*.sha512sum; do
			echo -e "\e[0;32mGPG signing $checksum\e[0m";
			gpg --homedir "$DOS_SIGNING_GPG" --sign --local-user "$DOS_GPG_SIGNING_KEY" --clearsign "$checksum";
			if [ "$?" -eq "0" ]; then
				mv -f "$checksum.asc" "$checksum";
			fi;
		done;
	fi;

	#Copy to archive
	if [ "$DOS_AUTO_ARCHIVE_BUILDS" = true ]; then
		echo -e "\e[0;32mCopying files to archive\e[0m";
		mkdir -vp $ARCHIVE;
		mkdir -vp $ARCHIVE/target_files;
		mkdir -vp $ARCHIVE/fastboot;
		mkdir -vp $ARCHIVE/incrementals;

		cp -v $OUT_DIR/$PREFIX-target_files.zip* $ARCHIVE/target_files/;
		cp -v $OUT_DIR/$PREFIX-fastboot.zip* $ARCHIVE/fastboot/ || true;
		cp -v $OUT_DIR/$PREFIX-ota.zip* $ARCHIVE/;
		cp -v $OUT_DIR/$PREFIX-incremental_*.zip* $ARCHIVE/incrementals/ || true;
		cp -v $OUT_DIR/$PREFIX-recovery.img* $ARCHIVE/ || true;

		rename -- "-ota." "." $ARCHIVE/$PREFIX-ota.zip*;
		rename -- "-incremental_" "-" $ARCHIVE/incrementals/$PREFIX-incremental_*.zip*;
		sync;

		#Remove to make space for next build
		if [ "$DOS_REMOVE_AFTER" = true ]; then
			echo -e "\e[0;32mRemoving to reclaim space\e[0m";
			#TODO: add a sanity check
			rm -rf "$OUT_DIR";
		fi;
	fi;

	sync;
	echo -e "\e[0;32mRelease processing complete\e[0m";
}
export -f processRelease;

pushToServer() {
	rsync -Pau --no-perms --no-owner --no-group incrementals/divested-*-dos-$1-*.zip* root@divestos.org:/var/www/divestos.org/builds/LineageOS/$1/incrementals/ || true;
	rsync -Pau --no-perms --no-owner --no-group divested-*-dos-$1.zip* root@divestos.org:/var/www/divestos.org/builds/LineageOS/$1/ || true;
	rsync -Pau --no-perms --no-owner --no-group divested-*-dos-$1-recovery.img root@divestos.org:/var/www/divestos.org/builds/LineageOS/$1/ || true;
	rsync -Pau --no-perms --no-owner --no-group fastboot/divested-*-dos-$1-*.zip* root@divestos.org:/var/www/divestos.org/builds/LineageOS/$1/ || true;
}
export -f pushToServer;

removeBuildFingerprints() {
	#Removes the stock/vendor fingerprint, allowing one to be generated instead
	find device -maxdepth 3 -name "lineage*.mk" -type f -exec sh -c "awk -i inplace '!/BUILD_FINGERPRINT/' {}" \;
	find device -maxdepth 3 -name "lineage*.mk" -type f -exec sh -c "awk -i inplace '!/PRIVATE_BUILD_DESC/' {}" \;
	echo "Removed stock build fingerprints";
}
export -f removeBuildFingerprints;

disableDexPreOpt() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		sed -i "s/WITH_DEXPREOPT := true/WITH_DEXPREOPT := false/" BoardConfig.mk;
		echo "Disabled dexpreopt";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f disableDexPreOpt;

compressRamdisks() {
	if [ -f BoardConfig.mk ]; then
		echo "LZMA_RAMDISK_TARGETS := boot,recovery" >> BoardConfig.mk;
		echo "Enabled ramdisk compression";
	fi;
}
export -f compressRamdisks;

addVerity() {
	echo 'ifeq ($(TARGET_BUILD_VARIANT),user)' >> device.mk;
	echo 'PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/by-name/system' >> device.mk;
	echo '$(call inherit-product, build/target/product/verity.mk)' >> device.mk;
	echo 'endif' >> device.mk;

	sed -i '/on init/a\\    verity_load_state' rootdir/etc/init."${PWD##*/}".rc;
	sed -i '/on early-boot/a\\    verity_update_state' rootdir/etc/init."${PWD##*/}".rc;
}
export -f addVerity;

enableVerity() {
	sed -i 's/--set_hashtree_disabled_flag//' *.mk;
	sed -i '/\/system/{/verify/!s|wait|wait,verify|}' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
}
export -f enableVerity;

optimizeImagesRecursive() {
	find "$1" -type f -name "*.jp*g" -print0 | xargs -0 -n1 -P 16 jpegoptim;
	find "$1" -type f -name "*.png" -print0 | xargs -0 -n1 -P 16 optipng;
}
export -f optimizeImagesRecursive;

smallerSystem() {
	echo "BOARD_SYSTEMIMAGE_JOURNAL_SIZE := 0" >> BoardConfig.mk;
	echo "PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true" >> BoardConfig.mk;
	echo "EXCLUDE_SERIF_FONTS := true" >> BoardConfig.mk;
	echo "SMALLER_FONT_FOOTPRINT := true" >> BoardConfig.mk;
	#echo "MINIMAL_FONT_FOOTPRINT := true" >> BoardConfig.mk;
	sed -i 's/common_full_phone.mk/common_mini_phone.mk/' *.mk &>/dev/null || true;
}
export -f smallerSystem;

deblobAudio() {
	awk -i inplace '!/BOARD_SUPPORTS_SOUND_TRIGGER/' hardware/qcom/audio-caf/*/configs/*/*.mk &>/dev/null || true;
	awk -i inplace '!/android.hardware.soundtrigger/' hardware/qcom/audio-caf/*/configs/*/*.mk &>/dev/null || true;
	awk -i inplace '!/DOLBY_/' hardware/qcom/audio-caf/*/configs/*/*.mk &>/dev/null || true;
	#awk -i inplace '!/vendor.audio.dolby/' hardware/qcom/audio-caf/*/configs/*/*.mk &>/dev/null || true;
}
export -f deblobAudio;

imsAllowDiag() {
       find device -name "ims.te" -type f -exec sh -c "echo 'diag_use(ims)' >> {}" \;
       find device -name "hal_imsrtp.te" -type f -exec sh -c "echo 'diag_use(hal_imsrtp)' >> {}" \;
}
export -f imsAllowDiag;

volteOverride() {
	cd "$DOS_BUILD_BASE$1";
	if grep -sq "config_device_volte_available" "overlay/frameworks/base/core/res/res/values/config.xml"; then
		if [ -f vendor.prop ] && ! grep -sq "volte_avail_ovr" "vendor.prop"; then
			echo -e 'persist.dbg.volte_avail_ovr=1\npersist.dbg.vt_avail_ovr=1' >> vendor.prop;
			echo "Set VoLTE override in vendor.prop for $1";
		fi;
		if [ -f vendor_prop.mk ] && ! grep -sq "volte_avail_ovr" "vendor_prop.mk"; then
			echo -e '\nPRODUCT_PROPERTY_OVERRIDES += \\\n    persist.dbg.volte_avail_ovr=1 \\\n    persist.dbg.vt_avail_ovr=1' >> vendor_prop.mk;
			echo "Set VoLTE override in vendor_prop.mk for $1";
		fi;
		#TODO: system.prop, init/init*.cpp, device*.mk
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f volteOverride;

hardenLocationConf() {
	local gpsConfig=$1;
	#Attempt to get the real device directory
	if [[ "$gpsConfig" = *"device/"* ]]; then
		local deviceDir=$(sed 's|gps/gps.conf||' <<< "$gpsConfig");
		deviceDir=$(sed 's|configs/gps.conf||' <<< "$deviceDir");
		deviceDir=$(sed 's|gps/etc/gps.conf||' <<< "$deviceDir");
		deviceDir=$(sed 's|gps.conf||' <<< "$deviceDir");
	else
		local deviceDir=$(dirname "$gpsConfig");
	fi;
	#Debugging: adb logcat -b all | grep -i -e locsvc -e izat -e gps -e gnss -e location -e xtra
	#sed -i 's|DEBUG_LEVEL = .|DEBUG_LEVEL = 4|' "$gpsConfig" &> /dev/null || true;
	#Enable GLONASS
	if [ "$DOS_GPS_GLONASS_FORCED" = true ]; then
	sed -i 's/#A_GLONASS_POS_PROTOCOL_SELECT =/A_GLONASS_POS_PROTOCOL_SELECT =/' "$gpsConfig" &>/dev/null || true;
	sed -i 's/A_GLONASS_POS_PROTOCOL_SELECT = 0.*/A_GLONASS_POS_PROTOCOL_SELECT = 15/' "$gpsConfig" &>/dev/null || true;
	fi;
	#Change capabilities
	sed -i 's|CAPABILITIES=.*|CAPABILITIES=0x13|' "$gpsConfig" &> /dev/null || true; #Disable MSA (privacy) and geofencing/ULP (both broken by deblobber)
	sed -i 's/#SUPL_MODE=/SUPL_MODE=/' "$gpsConfig" &>/dev/null || true;
	sed -i 's/SUPL_MODE=$/SUPL_MODE=1/' "$gpsConfig" &>/dev/null || true; #Set to MSB if blank (to prevent MSA+MSB default)
	sed -i "s|SUPL_MODE=3|SUPL_MODE=1|" "$gpsConfig" &> /dev/null || true; #Disable MSA (privacy)
	#CVE-2018-9526 - See: https://android.googlesource.com/device/google/marlin/+/fa7f7382e8b39f7ca209824f97788ab25c44f6a3
	sed -i 's/#SUPL_ES=/SUPL_ES=/' "$gpsConfig" &>/dev/null || true;
	sed -i "s|SUPL_ES=0|SUPL_ES=1|" "$gpsConfig" &> /dev/null || true;
	#Change servers
	sed -i "s|SUPL_HOST=.*|SUPL_HOST=$DOS_GPS_SUPL_HOST|" "$gpsConfig" &> /dev/null || true;
	sed -i "s|NTP_SERVER=.*|NTP_SERVER=$DOS_GPS_NTP_SERVER|" "$gpsConfig" &> /dev/null || true;
	#CVE-2016-5341 - See: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#XTRA: Only use specified URLs
	sed -i 's|XTRA_SERVER_QUERY=1|XTRA_SERVER_QUERY=0|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|#XTRA_SERVER|XTRA_SERVER|' "$gpsConfig" &>/dev/null || true;
	#Switch gpsOneXtra to IZatCloud (invalid certificate)
	sed -i '/xtrapath/!s|://xtra|://xtrapath|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|gpsonextra.net|izatcloud.net|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|xtrapath1|xtrapath4|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|xtrapath2|xtrapath5|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|xtrapath3|xtrapath6|' "$gpsConfig" &>/dev/null || true;
	#Enable HTTPS (IZatCloud supports HTTPS)
	sed -i 's|http://xtrapath|https://xtrapath|' "$gpsConfig" &>/dev/null || true;
	#sed -i 's|http://gllto|https://gllto|' "$gpsConfig" &>/dev/null || true; XXX: GLPals has an invaid certificate
	#XTRA: Use format version 3 if possible
	#if grep -sq "XTRA_VERSION_CHECK" "$gpsConfig"; then #Using hardware/qcom/gps OR precompiled blob OR device specific implementation
	#	sed -i 's|XTRA_VERSION_CHECK=0|XTRA_VERSION_CHECK=1|' "$gpsConfig" &>/dev/null || true;
	#	sed -i 's|xtra2.bin|xtra3grc.bin|' "$gpsConfig" &>/dev/null || true;
	#elif grep -sq "BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true" "$deviceDir"BoardConfig.mk "$deviceDir"boards/*gps.mk; then
	#	if ! grep -sq "USE_DEVICE_SPECIFIC_LOC_API := true" "$deviceDir"BoardConfig.mk "$deviceDir"boards/*gps.mk; then
	#		if ! grep -sq "libloc" ./"$deviceDir"/*proprietary*.txt; then #Using hardware/qcom/gps
	#			sed -i 's|xtra2.bin|xtra3grc.bin|' "$gpsConfig" &>/dev/null || true;
	#		fi;
	#	fi;
	#fi;
	#if [[ "$gpsConfig" = *"gps_debug.conf" ]]; then
	#	echo "XTRA_SERVER_1=https://xtrapath4.izatcloud.net/xtra2.bin" >> "$gpsConfig";
	#	echo "XTRA_SERVER_2=https://xtrapath5.izatcloud.net/xtra2.bin" >> "$gpsConfig";
	#	echo "XTRA_SERVER_3=https://xtrapath6.izatcloud.net/xtra2.bin" >> "$gpsConfig";
	#fi;
	echo "Enhanced location services for $gpsConfig";
}
export -f hardenLocationConf;

hardenLocationFWB() {
	local dir=$1;
	#Enable GLONASS
	if [ "$DOS_GPS_GLONASS_FORCED" = true ]; then
	sed -i 's|A_GLONASS_POS_PROTOCOL_SELECT=0.*</item>|A_GLONASS_POS_PROTOCOL_SELECT=15</item>|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	fi;
	#Change capabilities
	sed -i "s|SUPL_MODE=3|SUPL_MODE=1|" "$dir"/frameworks/base/core/res/res/values*/*.xml &> /dev/null || true; #Disable MSA (privacy)
	#CVE-2018-9526 - See: https://android.googlesource.com/device/google/marlin/+/fa7f7382e8b39f7ca209824f97788ab25c44f6a3
	sed -i "s|SUPL_ES=0|SUPL_ES=1|" "$dir"/frameworks/base/core/res/res/values*/*.xml &> /dev/null || true;
	#Change servers
	sed -i "s|NTP_SERVER=.*</item>|NTP_SERVER=$DOS_GPS_NTP_SERVER</item>|" "$dir"/frameworks/base/core/res/res/values*/*.xml &> /dev/null || true;
	#CVE-2016-5341 - See: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#Switch gpsOneXtra to IZatCloud (invalid certificate)
	sed -i '/xtrapath/!s|://xtra|://xtrapath|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	sed -i 's|gpsonextra.net|izatcloud.net|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	sed -i 's|xtrapath1|xtrapath4|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	sed -i 's|xtrapath2|xtrapath5|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	sed -i 's|xtrapath3|xtrapath6|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	#Enable HTTPS (IZatCloud supports HTTPS)
	sed -i 's|http://xtrapath|https://xtrapath|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	#sed -i 's|http://gllto|https://gllto|' "$dir"/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true; XXX: GLPals has an invaid certificate
	echo "Enhanced location services for $dir";
}
export -f hardenLocationFWB;

enableZram() {
	cd "$DOS_BUILD_BASE$1";
	sed -i 's|#/dev/block/zram0|/dev/block/zram0|' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
	echo "Enabled zram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableZram;

hardenUserdata() {
	cd "$DOS_BUILD_BASE$1";

	#awk -i inplace '!/f2fs/' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;

	#Remove latemount to allow selinux contexts be restored upon /cache wipe
	#Fixes broken OTA updater and broken /recovery updater
	sed -i '/\/cache/s|latemount,||' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;

	#TODO: Ensure: noatime,nosuid,nodev
	sed -i '/\/data/{/discard/!s|nosuid|discard,nosuid|}' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
	if [ "$1" != "device/samsung/tuna" ]; then #tuna needs first boot to init
		sed -i 's|encryptable=/|forceencrypt=/|' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
	fi;
	echo "Hardened /data for $1";
	cd "$DOS_BUILD_BASE";
}
export -f hardenUserdata;

hardenBootArgs() {
	cd "$DOS_BUILD_BASE$1";
	#Unavailable: kpti=on pti=on page_alloc.shuffle=1 init_on_alloc=1 init_on_free=1 lockdown=confidentiality
	sed -i 's/BOARD_KERNEL_CMDLINE := /BOARD_KERNEL_CMDLINE := slab_nomerge slub_debug=FZP page_poison=1 /' BoardConfig*.mk */BoardConfig*.mk &>/dev/null || true;
	echo "Hardened kernel command line arguments for $1";
	cd "$DOS_BUILD_BASE";
}
export -f hardenBootArgs;

enableStrongEncryption() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		echo "TARGET_WANTS_STRONG_ENCRYPTION := true" >> BoardConfig.mk;
		echo "Enabled AES-256 encryption for $1";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableStrongEncryption;

changeDefaultDNS() {
	local dnsPrimary="";
	local dnsPrimaryV6="";
	local dnsSecondary="";
	local dnsSecondaryV6="";
	if [ -z "$DNS_PRESET" ]; then
		if [[ "$DOS_DEFAULT_DNS_PRESET" == "AdGuard" ]]; then #https://adguard.com/en/adguard-dns/overview.html
			dnsPrimary="176.103.130.130";
			dnsPrimaryV6="2a00:5a60::ad1:0ff";
			dnsSecondary="176.103.130.131";
			dnsSecondaryV6="2a00:5a60::ad2:0ff";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "AdGuard-NOBL" ]]; then #https://adguard.com/en/adguard-dns/overview.html
			dnsPrimary="176.103.130.136";
			dnsPrimaryV6="2a00:5a60::01:ff";
			dnsSecondary="176.103.130.137";
			dnsSecondaryV6="2a00:5a60::02:ff";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "CensurfriDNS" ]]; then #https://uncensoreddns.org
			dnsPrimary="91.239.100.100";
			dnsPrimaryV6="2001:67c:28a4::";
			dnsSecondary="89.233.43.71";
			dnsSecondaryV6="2a01:3a0:53:53::";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Cloudflare" ]]; then #https://developers.cloudflare.com/1.1.1.1/commitment-to-privacy/privacy-policy/privacy-policy
			dnsPrimary="1.0.0.1";
			dnsPrimaryV6="2606:4700:4700::1001";
			dnsSecondary="1.1.1.1";
			dnsSecondaryV6="2606:4700:4700::1111";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Cloudflare-BL" ]]; then #https://developers.cloudflare.com/1.1.1.1/commitment-to-privacy/privacy-policy/privacy-policy
			dnsPrimary="1.0.0.2";
			dnsPrimaryV6="2606:4700:4700::1002";
			dnsSecondary="1.1.1.2";
			dnsSecondaryV6="2606:4700:4700::1112";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "OpenNIC" ]]; then #https://servers.opennicproject.org/edit.php?srv=ns3.any.dns.opennic.glue
			dnsPrimary="169.239.202.202"; #FIXME
			dnsPrimaryV6="2a05:dfc7:5353::53";
			dnsSecondary="185.121.177.177";
			dnsSecondaryV6="2a05:dfc7:5::53";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "DNSWATCH" ]]; then #https://dns.watch
			dnsPrimary="84.200.69.80";
			dnsPrimaryV6="2001:1608:10:25::1c04:b12f";
			dnsSecondary="84.200.70.40";
			dnsSecondaryV6="2001:1608:10:25::9249:d69b";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Google" ]]; then #https://developers.google.com/speed/public-dns/privacy
			dnsPrimary="8.8.8.8";
			dnsPrimaryV6="2001:4860:4860::8888";
			dnsSecondary="8.8.4.4";
			dnsSecondaryV6="2001:4860:4860::8844";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Neustar" ]]; then #https://www.security.neustar/digital-performance/dns-services/recursive-dns
			dnsPrimary="156.154.70.2";
			dnsPrimaryV6="2610:a1:1018::2";
			dnsSecondary="156.154.71.2";
			dnsSecondaryV6="2610:a1:1019::2";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Neustar-NOBL" ]]; then #https://www.security.neustar/digital-performance/dns-services/recursive-dns
			dnsPrimary="156.154.70.5";
			dnsPrimaryV6="2610:a1:1018::5";
			dnsSecondary="156.154.71.5";
			dnsSecondaryV6="2610:a1:1019::5";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "NixNet" ]]; then #https://docs.nixnet.services/DNS
			dnsPrimary="198.251.90.114";
			dnsPrimaryV6="2605:6400:20:e6d::1";
			dnsSecondary="198.251.90.114";
			dnsSecondaryV6="2605:6400:30:f881::1";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "OpenDNS" ]]; then #https://www.cisco.com/c/en/us/about/legal/privacy-full.html
			dnsPrimary="208.67.222.222";
			dnsPrimaryV6="2620:0:ccc::2";
			dnsSecondary="208.67.220.220";
			dnsSecondaryV6="2620:0:ccd::2";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Quad9" ]]; then #https://www.quad9.net/privacy
			dnsPrimary="9.9.9.9";
			dnsPrimaryV6="2620:fe::fe";
			dnsSecondary="149.112.112.112";
			dnsSecondaryV6="2620:fe::9";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Quad9-EDNS" ]]; then #https://www.quad9.net/privacy
			dnsPrimary="9.9.9.11";
			dnsPrimaryV6="2620:fe::11";
			dnsSecondary="149.112.112.11";
			dnsSecondaryV6="2620:fe::fe:11";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Quad9-NOBL" ]]; then #https://www.quad9.net/privacy
			dnsPrimary="9.9.9.10";
			dnsPrimaryV6="2620:fe::10";
			dnsSecondary="149.112.112.10";
			dnsSecondaryV6="2620:fe::fe:10";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Verisign" ]]; then #https://www.verisign.com/en_US/security-services/public-dns/terms-of-service/index.xhtml
			dnsPrimary="64.6.64.6";
			dnsPrimaryV6="2620:74:1b::1:1";
			dnsSecondary="64.6.65.6";
			dnsSecondaryV6="2620:74:1c::2:2";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Yandex" ]]; then #https://dns.yandex.com/advanced
			dnsPrimary="77.88.8.88";
			dnsPrimaryV6="2a02:6b8::feed:bad";
			dnsSecondary="77.88.8.2";
			dnsSecondaryV6="2a02:6b8:0:1::feed:bad";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Yandex-NOBL" ]]; then #https://dns.yandex.com/advanced
			dnsPrimary="77.88.8.8";
			dnsPrimaryV6="2a02:6b8::feed:0ff";
			dnsSecondary="77.88.8.1";
			dnsSecondaryV6="2a02:6b8:0:1::feed:0ff";
		fi;
	else
		echo "You must first set a preset via the DEFAULT_DNS_PRESET variable in init.sh!";
	fi;

	local files="core/res/res/values/config.xml packages/SettingsLib/res/values/strings.xml services/core/java/com/android/server/connectivity/NetworkDiagnostics.java services/core/java/com/android/server/connectivity/Tethering.java services/core/java/com/android/server/connectivity/tethering/TetheringConfiguration.java services/java/com/android/server/connectivity/Tethering.java";
	sed -i "s/8\.8\.8\.8/$dnsPrimary/" $files &>/dev/null || true;
	sed -i "s/2001:4860:4860::8888/$dnsPrimaryV6/" $files &>/dev/null || true;
	sed -i "s/8\.8\.4\.4/$dnsSecondary/" $files &>/dev/null || true;
	sed -i "s/4\.4\.4\.4/$dnsSecondary/" $files &>/dev/null || true;
	sed -i "s/2001:4860:4860::8844/$dnsSecondaryV6/" $files &>/dev/null || true;
}
export -f changeDefaultDNS;

editKernelLocalversion() {
	local defconfigPath=$(getDefconfig)
	sed -i 's/CONFIG_LOCALVERSION=".*"/CONFIG_LOCALVERSION="'"$1"'"/' $defconfigPath &>/dev/null || true;
}
export -f editKernelLocalversion;

getDefconfig() {
	if ls arch/arm/configs/lineage*defconfig 1> /dev/null 2>&1; then
		local defconfigPath="arch/arm/configs/lineage*defconfig";
	elif ls arch/arm64/configs/lineage*defconfig 1> /dev/null 2>&1; then
		local defconfigPath="arch/arm64/configs/lineage*defconfig";
	else
		local defconfigPath="arch/arm/configs/*defconfig arch/arm64/configs/*defconfig";
	fi;
	echo $defconfigPath;
}
export -f getDefconfig;

hardenDefconfig() {
	cd "$DOS_BUILD_BASE$1";

	#Attempts to enable/disable supported options to increase security
	#See https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Recommended_Settings
	#and https://github.com/a13xp0p0v/kconfig-hardened-check/blob/master/kconfig-hardened-check.py

	local defconfigPath=$(getDefconfig)

	#Enable supported options
	#Disabled: DEBUG_SG (bootloops - https://patchwork.kernel.org/patch/8989981)
	declare -a optionsYes=("ARM64_PTR_AUTH" "ARM64_SW_TTBR0_PAN" "ARM64_UAO" "ASYMMETRIC_KEY_TYPE" "ASYMMETRIC_PUBLIC_KEY_SUBTYPE" "BUG" "BUG_ON_DATA_CORRUPTION" "CC_STACKPROTECTOR" "CC_STACKPROTECTOR_STRONG" "CPU_SW_DOMAIN_PAN" "DEBUG_CREDENTIALS" "DEBUG_KERNEL" "DEBUG_LIST" "DEBUG_NOTIFIERS" "DEBUG_RODATA" "DEBUG_SET_MODULE_RONX" "DEBUG_VIRTUAL" "DEBUG_WX" "FORTIFY_SOURCE" "HARDEN_BRANCH_PREDICTOR" "HARDENED_USERCOPY" "HARDEN_EL2_VECTORS" "INIT_ON_ALLOC_DEFAULT_ON" "INIT_ON_FREE_DEFAULT_ON" "INIT_STACK_ALL" "INIT_STACK_ALL_ZERO" "IO_STRICT_DEVMEM" "IPV6_PRIVACY" "KAISER" "KGSL_PER_PROCESS_PAGE_TABLE" "LEGACY_VSYSCALL_NONE" "MMC_SECDISCARD" "PAGE_POISONING" "PAGE_POISONING_NO_SANITY" "PAGE_POISONING_ZERO" "PAGE_TABLE_ISOLATION" "PANIC_ON_OOPS" "PKCS7_MESSAGE_PARSER" "RANDOMIZE_BASE" "RANDOMIZE_MEMORY" "REFCOUNT_FULL" "RETPOLINE" "RODATA_FULL_DEFAULT_ENABLED" "SCHED_STACK_END_CHECK" "SECCOMP" "SECCOMP_FILTER" "SECURITY" "SECURITY_DMESG_RESTRICT" "SECURITY_PERF_EVENTS_RESTRICT" "SECURITY_YAMA" "SECURITY_YAMA_STACKED" "SHUFFLE_PAGE_ALLOCATOR" "SLAB_FREELIST_HARDENED" "SLAB_FREELIST_RANDOM" "SLAB_HARDENED" "SLUB_DEBUG" "SLUB_HARDENED" "STACKPROTECTOR" "STACKPROTECTOR_PER_TASK" "STACKPROTECTOR_STRONG" "STATIC_USERMODEHELPER" "STRICT_DEVMEM" "STRICT_KERNEL_RWX" "STRICT_MEMORY_RWX" "STRICT_MODULE_RWX" "SYN_COOKIES" "SYSTEM_TRUSTED_KEYRING" "THREAD_INFO_IN_TASK" "UNMAP_KERNEL_AT_EL0" "VMAP_STACK" "X509_CERTIFICATE_PARSER");
	#optionsYes+="GCC_PLUGINS" "GCC_PLUGIN_LATENT_ENTROPY" "GCC_PLUGIN_RANDSTRUCT" "GCC_PLUGIN_STRUCTLEAK" "GCC_PLUGIN_STRUCTLEAK_BYREF_ALL");
	optionsYes+=("PAGE_SANITIZE" "PAGE_SANITIZE_VERIFY" "SLAB_CANARY" "SLAB_SANITIZE" "SLAB_SANITIZE_VERIFY");
	#if [ "$DOS_DEBLOBBER_REPLACE_TIME" = true ]; then optionsYes+=("RTC_DRV_MSM" "RTC_DRV_PM8XXX" "RTC_DRV_MSM7X00A" "RTC_DRV_QPNP"); fi;
	for option in "${optionsYes[@]}"
	do
		sed -i 's/# '"CONFIG_$option"' is not set/'"CONFIG_$option"'=y/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ "$defconfigPath" == *"lineage"* ]]; then
			if ! grep -q "CONFIG_$option=y" $defconfigPath; then
				echo "CONFIG_$option=y" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
	done
	#Disable supported options
	#Disabled: MSM_SMP2P_TEST, MAGIC_SYSRQ (breaks compile), KALLSYMS (breaks boot on select devices), IKCONFIG (breaks recovery), MSM_DLOAD_MODE (breaks compile)
	declare -a optionsNo=("ACPI_APEI_EINJ" "ACPI_CUSTOM_METHOD" "ACPI_TABLE_UPGRADE" "BINFMT_AOUT" "BINFMT_MISC" "BT_HS" "CHECKPOINT_RESTORE" "COMPAT_BRK" "COMPAT_VDSO" "CP_ACCESS64" "DEBUG_KMEMLEAK" "DEVKMEM" "DEVMEM" "DEVPORT" "EARJACK_DEBUGGER" "GCC_PLUGIN_RANDSTRUCT_PERFORMANCE" "HARDENED_USERCOPY_FALLBACK" "HIBERNATION" "HWPOISON_INJECT" "IA32_EMULATION" "IOMMU_NON_SECURE" "INPUT_EVBUG" "IP_DCCP" "IP_SCTP" "KEXEC" "KEXEC_FILE" "KSM" "LDISC_AUTOLOAD" "LEGACY_PTYS" "LIVEPATCH" "MEM_SOFT_DIRTY" "MMIOTRACE" "MMIOTRACE_TEST" "MODIFY_LDT_SYSCALL" "MSM_BUSPM_DEV" "NEEDS_SYSCALL_FOR_CMPXCHG" "NOTIFIER_ERROR_INJECTION" "OABI_COMPAT" "PAGE_OWNER" "PROC_KCORE" "PROC_PAGE_MONITOR" "PROC_VMCORE" "RDS" "RDS_TCP" "SECURITY_SELINUX_DISABLE" "SECURITY_WRITABLE_HOOKS" "SLAB_MERGE_DEFAULT" "STACKLEAK_METRICS" "STACKLEAK_RUNTIME_DISABLE" "TIMER_STATS" "TSC" "TSPP2" "UKSM" "UPROBES" "USELIB" "USERFAULTFD" "VIDEO_VIVID" "WLAN_FEATURE_MEMDUMP" "X86_IOPL_IOPERM" "X86_PTDUMP" "X86_VSYSCALL_EMULATION" "ZSMALLOC_STAT");
	#if [[ "$1" != *"kernel/htc/msm8994"* ]] && [[ "$1" != *"kernel/samsung/smdk4412"* ]] && [[ "$1" != *"kernel/htc/flounder"* ]] && [[ "$1" != *"kernel/amazon/hdx-common"* ]] && [[ "$1" != *"msm899"* ]] && [[ "$1" != *"sdm8"* ]] && [[ "$1" != *"sdm6"* ]]; then
		#optionsNo+=("DIAG_CHAR" "DIAG_OVER_USB" "USB_QCOM_DIAG_BRIDGE" "DIAGFWD_BRIDGE_CODE" "DIAG_SDIO_PIPE" "DIAG_HSIC_PIPE");
	#fi;
	if [ "$DOS_DEBLOBBER_REMOVE_IPA" = true ]; then optionsNo+=("IPA" "RMNET_IPA"); fi;
	for option in "${optionsNo[@]}"
	do
		sed -i 's/'"CONFIG_$option"'=y/# '"CONFIG_$option"' is not set/' $defconfigPath &>/dev/null || true;
		#sed -i 's/'"CONFIG_$option"'=y/'"CONFIG_$option"'=n/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ "$defconfigPath" == *"lineage"* ]]; then
			if ! grep -q "CONFIG_$option=n" $defconfigPath; then
				echo "CONFIG_$option=n" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
	done
	#Extras
	sed -i 's/CONFIG_ARCH_MMAP_RND_BITS=8/CONFIG_ARCH_MMAP_RND_BITS=16/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_ARCH_MMAP_RND_BITS=18/CONFIG_ARCH_MMAP_RND_BITS=24/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_DEFAULT_MMAP_MIN_ADDR=4096/CONFIG_DEFAULT_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_LSM_MMAP_MIN_ADDR=4096/CONFIG_LSM_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;

	#Resurrect dm-verity XXX: This needs a better home
	sed -i 's/^\treturn VERITY_STATE_DISABLE;//' drivers/md/dm-android-verity.c &>/dev/null || true;
	#sed -i 's/#if 0/#if 1/' drivers/power/reset/msm-poweroff.c &>/dev/null || true;

	#Workaround broken MSM_DLOAD_MODE=y+PANIC_ON_OOPS=y for devices that oops on shutdown
	#MSM_DLOAD_MODE can't be disabled as it breaks compile
	sed -i 's/set_dload_mode(in_panic)/set_dload_mode(0)/' arch/arm/mach-msm/restart.c &>/dev/null || true;

	editKernelLocalversion "-dos";

	echo "Hardened defconfig for $1";
	cd "$DOS_BUILD_BASE";
}
export -f hardenDefconfig;
