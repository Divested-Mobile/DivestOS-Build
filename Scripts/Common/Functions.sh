#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing, Inc.
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
	java -jar "$DOS_BINARY_PATCHER" patch "$DOS_BUILD_BASE" "$DOS_WORKSPACE_ROOT""Patches/" "$DOS_SCRIPTS_CVES" $1;
}
export -f startPatcher;

enter() {
	echo "================================================================================================"
	dir="$1";
	cd "$DOS_BUILD_BASE$dir";
	echo "[ENTERING] $dir";
}
export -f enter;

enterAndClear() {
	enter "$1";
	gitReset;
}
export -f enterAndClear;

gitReset() {
	git add -A && git reset --hard;
}
export -f gitReset;

scanForMalware() {
	if [ -x /usr/bin/clamscan ] && [ -r /var/lib/clamav/main.cvd ]; then
		echo -e "\e[0;32mStarting a malware scan...\e[0m";
		excludes="--exclude-dir=\".git\" --exclude-dir=\".repo\"";
		scanQueue="$2";
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
		du -hsc "$scanQueue";
		/usr/bin/clamscan --recursive --detect-pua --infected "$excludes" "$scanQueue";
		clamscanExit="$?";
		if [ "$clamscanExit" -eq "1" ]; then
			echo -e "\e[0;31m----------------------------------------------------------------\e[0m";
			echo -e "\e[0;31mWARNING: MALWARE WAS FOUND! PLEASE INVESTIGATE!\e[0m";
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
	text=$1;
	font=$2
	output=$3;
	convert -background black -fill transparent -font "$font" -gravity center -size 512x128 label:"$text" "$output";
}
export -f generateBootAnimationMask;

generateBootAnimationShine() {
	color=$1;
	style=$2;
	output=$3;
	#The colors need to be symmetrical in order to make the animation smooth and not have any noticble lines
	convert -size 1024x128 -define gradient:angle=90 "$style":"$color" \( +clone -flop \) +append "$output";
}
export -f generateBootAnimationShine;

audit2allowCurrent() {
	adb shell dmesg | audit2allow -p "$ANDROID_PRODUCT_OUT"/root/sepolicy;
}
export -f audit2allowCurrent;

audit2allowADB() {
	adb pull /sys/fs/selinux/policy;
	adb logcat -b all -d | audit2allow -p policy;
}
export -f audit2allowADB;

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

enhanceLocation() {
	gpsConfig=$1;
	#Attempt to get the real device directory
	if [[ "$gpsConfig" = *"device/"* ]]; then
		deviceDir=$(sed 's|gps/gps.conf||' <<< "$gpsConfig");
		deviceDir=$(sed 's|configs/gps.conf||' <<< "$deviceDir");
		deviceDir=$(sed 's|gps/etc/gps.conf||' <<< "$deviceDir");
		deviceDir=$(sed 's|gps.conf||' <<< "$deviceDir");
	else
		deviceDir=$(dirname "$gpsConfig");
	fi;
	#Debugging (adb logcat | grep -i -e locsvc -e izat -e gps -e geo -e location)
	#sed -i 's|DEBUG_LEVEL = .|DEBUG_LEVEL = 4|' "$gpsConfig" &> /dev/null || true;
	#Enable GLONASS
	if [ "$DOS_GPS_GLONASS_FORCED" = true ]; then
	sed -i 's/#A_GLONASS_POS_PROTOCOL_SELECT/A_GLONASS_POS_PROTOCOL_SELECT/' "$gpsConfig" &>/dev/null || true;
	sed -i 's/A_GLONASS_POS_PROTOCOL_SELECT = 0.*/A_GLONASS_POS_PROTOCOL_SELECT = 15/' "$gpsConfig" &>/dev/null || true;
	sed -i 's|A_GLONASS_POS_PROTOCOL_SELECT=0.*</item>|A_GLONASS_POS_PROTOCOL_SELECT=15</item>|' "$deviceDir"overlay/frameworks/base/core/res/res/values*/*.xml &>/dev/null || true;
	fi;
	#Change capabilities
	sed -i 's|CAPABILITIES=.*|CAPABILITIES=0x33|' "$gpsConfig" &> /dev/null || true; #Disable (?) MSA. 0x20 is used for both ULP and geofencing
	#Change servers
	sed -i "s|SUPL_HOST=.*|SUPL_HOST=$DOS_GPS_SUPL_HOST|" "$gpsConfig" &> /dev/null || true;
	sed -i "s|NTP_SERVER=.*|NTP_SERVER=$DOS_GPS_NTP_SERVER|" "$gpsConfig" &> /dev/null || true;
	#Recommended reading: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#XTRA: Only use specified URLs
	sed -i 's|XTRA_SERVER_QUERY=1|XTRA_SERVER_QUERY=0|' "$gpsConfig" &>/dev/null || true;
	sed -i 's|#XTRA_SERVER|XTRA_SERVER|' "$gpsConfig" &>/dev/null || true;
	#Switch gpsOneXtra to IZatCloud (invalid certificate)
	sed -i '/xtrapath/!s|://xtra|://xtrapath|' "$deviceDir"overlay/frameworks/base/core/res/res/values*/*.xml "$gpsConfig" &>/dev/null || true;
	sed -i 's|gpsonextra.net|izatcloud.net|' "$deviceDir"overlay/frameworks/base/core/res/res/values*/*.xml "$gpsConfig" &>/dev/null || true;
	#Enable HTTPS (IZatCloud supports HTTPS)
	sed -i 's|http://xtrapath|https://xtrapath|' "$deviceDir"overlay/frameworks/base/core/res/res/values*/*.xml "$gpsConfig" &>/dev/null || true;
	#sed -i 's|http://gllto|https://gllto|' "$deviceDir"overlay/frameworks/base/core/res/res/values*/*.xml "$gpsConfig" &>/dev/null || true; XXX: GLPals has an invaid certificate
	#XTRA: Use format version 3 if possible
	if grep -sq "XTRA_VERSION_CHECK" "$gpsConfig"; then #Using hardware/qcom/gps OR precompiled blob OR device specific implementation
		sed -i 's|XTRA_VERSION_CHECK=0|XTRA_VERSION_CHECK=1|' "$gpsConfig" &>/dev/null || true;
		sed -i 's|xtra2.bin|xtra3grc.bin|' "$gpsConfig" &>/dev/null || true;
	elif grep -sq "BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true" "$deviceDir"BoardConfig.mk "$deviceDir"boards/*gps.mk; then
		if ! grep -sq "USE_DEVICE_SPECIFIC_LOC_API := true" "$deviceDir"BoardConfig.mk "$deviceDir"boards/*gps.mk; then
			if ! grep -sq "libloc" ./"$deviceDir"/*proprietary*.txt; then #Using hardware/qcom/gps
				sed -i 's|xtra2.bin|xtra3grc.bin|' "$gpsConfig" &>/dev/null || true;
			fi;
		fi;
	fi;
	echo "Enhanced location services for $deviceDir";
}
export -f enhanceLocation;

enableZram() {
	cd "$DOS_BUILD_BASE$1";
	sed -i 's|#/dev/block/zram0|/dev/block/zram0|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
	echo "Enabled zram for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableZram;

enableForcedEncryption() {
	cd "$DOS_BUILD_BASE$1";
	sed -i 's|encryptable=/|forceencrypt=/|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
	echo "Enabled forceencrypt for $1";
	cd "$DOS_BUILD_BASE";
}
export -f enableForcedEncryption;

enableStrongEncryption() {
	cd "$DOS_BUILD_BASE$1";
	if [ -f BoardConfig.mk ]; then
		echo "TARGET_WANTS_STRONG_ENCRYPTION := true" >> BoardConfig.mk;
		echo "Enabled AES-256 encryption for $1";
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f enableStrongEncryption;

getDefconfig() {
	if ls arch/arm/configs/lineage*defconfig 1> /dev/null 2>&1; then
		defconfigPath="arch/arm/configs/lineage*defconfig";
	elif ls arch/arm64/configs/lineage*defconfig 1> /dev/null 2>&1; then
		defconfigPath="arch/arm64/configs/lineage*defconfig";
	else
		defconfigPath="arch/arm/configs/*defconfig arch/arm64/configs/*defconfig";
	fi;
	echo $defconfigPath;
	#echo "Found defconfig at $defconfigPath"
}
export -f getDefconfig;

changeDefaultDNS() {
	dnsPrimary="";
	dnsPrimaryV6="";
	dnsSecondary="";
	dnsSecondaryV6="";
	if [ -z "$DNS_PRESET" ]; then
		if [[ "$DOS_DEFAULT_DNS_PRESET" == "Cloudflare" ]]; then #https://developers.cloudflare.com/1.1.1.1/commitment-to-privacy/privacy-policy/privacy-policy/
			dnsPrimary="1.0.0.1";
			dnsPrimaryV6="2606:4700:4700::1001";
			dnsSecondary="1.1.1.1";
			dnsSecondaryV6="2606:4700:4700::1111";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "OpenNIC" ]]; then #https://servers.opennicproject.org/edit.php?srv=ns3.any.dns.opennic.glue
			dnsPrimary="169.239.202.202"; #RIP
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
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "OpenDNS" ]]; then #https://www.cisco.com/c/en/us/about/legal/privacy-full.html
			dnsPrimary="208.67.222.222";
			dnsPrimaryV6="2620:0:ccc::2";
			dnsSecondary="208.67.220.220";
			dnsSecondaryV6="2620:0:ccd::2";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Quad9" ]]; then #https://www.quad9.net/privacy/
			dnsPrimary="9.9.9.9";
			dnsPrimaryV6="2620:fe::fe";
			dnsSecondary="149.112.112.112";
			dnsSecondaryV6="2620:fe::fe"; #no secondary available
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Quad9U" ]]; then #https://www.quad9.net/privacy/
			dnsPrimary="9.9.9.10";
			dnsPrimaryV6="2620:fe::10";
			dnsSecondary="149.112.112.10";
			dnsSecondaryV6="2620:fe::10"; #no secondary available
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Verisign" ]]; then #https://www.verisign.com/en_US/security-services/public-dns/terms-of-service/index.xhtml
			dnsPrimary="64.6.64.6";
			dnsPrimaryV6="2620:74:1b::1:1";
			dnsSecondary="64.6.65.6";
			dnsSecondaryV6="2620:74:1c::2:2";
		fi;
	else
		echo "You must first set a preset via the DEFAULT_DNS_PRESET variable in init.sh!";
	fi;

	files="core/res/res/values/config.xml packages/SettingsLib/res/values/strings.xml services/core/java/com/android/server/connectivity/NetworkDiagnostics.java services/core/java/com/android/server/connectivity/Tethering.java services/core/java/com/android/server/connectivity/tethering/TetheringConfiguration.java services/java/com/android/server/connectivity/Tethering.java";
	sed -i "s/8\.8\.8\.8/$dnsPrimary/" $files &>/dev/null || true;
	sed -i "s/2001:4860:4860::8888/$dnsPrimaryV6/" $files &>/dev/null || true;
	sed -i "s/8\.8\.4\.4/$dnsSecondary/" $files &>/dev/null || true;
	sed -i "s/2001:4860:4860::8844/$dnsSecondaryV6/" $files &>/dev/null || true;
}
export -f changeDefaultDNS;

editKernelLocalversion() {
	defconfigPath=$(getDefconfig)
	sed -i 's/CONFIG_LOCALVERSION=".*"/CONFIG_LOCALVERSION="'"$1"'"/' $defconfigPath &>/dev/null || true;
}
export -f editKernelLocalversion;

hardenDefconfig() {
	cd "$DOS_BUILD_BASE$1";

	#Attempts to enable/disable supported options to increase security
	#See https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Recommended_Settings

	defconfigPath=$(getDefconfig)

	#Enable supported options
	#Disabled: CONFIG_DEBUG_SG (bootloops - https://patchwork.kernel.org/patch/8989981)
	declare -a optionsYes=("CONFIG_ARM64_SW_TTBR0_PAN" "CONFIG_BUG" "CONFIG_BUG_ON_DATA_CORRUPTION" "CONFIG_CC_STACKPROTECTOR" "CONFIG_CC_STACKPROTECTOR_STRONG" "CONFIG_CPU_SW_DOMAIN_PAN" "CONFIG_DEBUG_CREDENTIALS" "CONFIG_DEBUG_KERNEL" "CONFIG_DEBUG_LIST" "CONFIG_DEBUG_NOTIFIERS" "CONFIG_DEBUG_RODATA" "CONFIG_DEBUG_WX" "CONFIG_FORTIFY_SOURCE" "CONFIG_GCC_PLUGIN_LATENT_ENTROPY" "CONFIG_GCC_PLUGIN_RANDSTRUCT" "CONFIG_GCC_PLUGINS" "CONFIG_GCC_PLUGIN_STRUCTLEAK" "CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL" "CONFIG_HARDENED_USERCOPY" "CONFIG_IO_STRICT_DEVMEM" "CONFIG_KAISER" "CONFIG_LEGACY_VSYSCALL_NONE" "CONFIG_PAGE_POISONING" "CONFIG_PAGE_POISONING_NO_SANITY" "CONFIG_PAGE_POISONING_ZERO" "CONFIG_PAGE_TABLE_ISOLATION" "CONFIG_PANIC_ON_OOPS" "CONFIG_RANDOMIZE_BASE" "CONFIG_REFCOUNT_FULL" "CONFIG_RETPOLINE" "CONFIG_SCHED_STACK_END_CHECK" "CONFIG_SECCOMP" "CONFIG_SECCOMP_FILTER" "CONFIG_SECURITY" "CONFIG_SECURITY_PERF_EVENTS_RESTRICT" "CONFIG_SECURITY_YAMA" "CONFIG_SECURITY_YAMA_STACKED" "CONFIG_SLAB_FREELIST_RANDOM" "CONFIG_SLAB_HARDENED" "CONFIG_SLUB_DEBUG" "CONFIG_STRICT_DEVMEM" "CONFIG_STRICT_KERNEL_RWX" "CONFIG_STRICT_MEMORY_RWX" "CONFIG_SYN_COOKIES" "CONFIG_UNMAP_KERNEL_AT_EL0" "CONFIG_VMAP_STACK" "CONFIG_SECURITY_DMESG_RESTRICT" "CONFIG_SLAB_FREELIST_HARDENED" "CONFIG_GCC_PLUGINS" "CONFIG_GCC_PLUGIN_LATENT_ENTROPY" "CONFIG_GCC_PLUGIN_STRUCTLEAK" "CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL" "CONFIG_GCC_PLUGIN_RANDSTRUCT" "CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE")
	for option in "${optionsYes[@]}"
	do
		sed -i 's/# '"$option"' is not set/'"$option"'=y/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ "$defconfigPath" == *"lineage"* ]]; then
			if ! grep -q "$option""=y" $defconfigPath; then
				echo "$option""=y" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
	done
	#Disable supported options
	declare -a optionsNo=("CONFIG_ACPI_CUSTOM_METHOD" "CONFIG_BINFMT_MISC" "CONFIG_COMPAT_BRK" "CONFIG_COMPAT_VDSO" "CONFIG_CP_ACCESS64" "CONFIG_DEVKMEM" "CONFIG_DEVMEM" "CONFIG_DEVPORT" "CONFIG_HIBERNATION" "CONFIG_INET_DIAG" "CONFIG_KEXEC" "CONFIG_LEGACY_PTYS" "CONFIG_MSM_BUSPM_DEV" "CONFIG_OABI_COMPAT" "CONFIG_PROC_KCORE" "CONFIG_PROC_VMCORE" "CONFIG_SECURITY_SELINUX_DISABLE" "CONFIG_SLAB_MERGE_DEFAULT" "CONFIG_WLAN_FEATURE_MEMDUMP" "CONFIG_EARJACK_DEBUGGER");
	#if [ "$DOS_DEBLOBBER_REMOVE_IPA" = true ]; then optionsNo+=("CONFIG_MSM"); fi;
	for option in "${optionsNo[@]}"
	do
		sed -i 's/'"$option"'=y/# '"$option"' is not set/' $defconfigPath &>/dev/null || true;
	done
	#Extras
	sed -i 's/CONFIG_ARCH_MMAP_RND_BITS=8/CONFIG_ARCH_MMAP_RND_BITS=16/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_ARCH_MMAP_RND_BITS=18/CONFIG_ARCH_MMAP_RND_BITS=24/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_DEFAULT_MMAP_MIN_ADDR=4096/CONFIG_DEFAULT_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_LSM_MMAP_MIN_ADDR=4096/CONFIG_LSM_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;

	editKernelLocalversion "-dos";

	echo "Hardened defconfig for $1";
	cd "$DOS_BUILD_BASE";
}
export -f hardenDefconfig;
