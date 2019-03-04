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
	dirReal="$DOS_BUILD_BASE$dir";
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
	if enter "$1"; then gitReset; fi;
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
	adb logcat -b all -d | audit2allow -p "$ANDROID_PRODUCT_OUT"/root/sepolicy;
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

hardenLocationConf() {
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
	#Debugging (adb logcat | grep -i -e locsvc -e izat -e gps -e gnss -e location)
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
	#Enable HTTPS (IZatCloud supports HTTPS)
	sed -i 's|http://xtrapath|https://xtrapath|' "$gpsConfig" &>/dev/null || true;
	#sed -i 's|http://gllto|https://gllto|' "$gpsConfig" &>/dev/null || true; XXX: GLPals has an invaid certificate
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
	echo "Enhanced location services for $gpsConfig";
}
export -f hardenLocationConf;

hardenLocationFWB() {
	dir=$1;
	#Debugging (adb logcat | grep -i -e locsvc -e izat -e gps -e gnss -e location)
	#sed -i 's|DEBUG_LEVEL = .|DEBUG_LEVEL = 4|' "$gpsConfig" &> /dev/null || true;
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

	#Remove latemount to allow selinux contexts be restored upon /cache wipe
	#Fixes broken OTA updater and broken /recovery updater
	sed -i '/\/cache/s|latemount,||' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;

	#TODO: Ensure: noatime,nosuid,nodev
	sed -i '/\/data/{/discard/!s|nosuid|discard,nosuid|}' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
	sed -i 's|encryptable=/|forceencrypt=/|' fstab.* root/fstab.* rootdir/fstab.* rootdir/*/fstab.* &>/dev/null || true;
	echo "Hardened /data for $1";
	cd "$DOS_BUILD_BASE";
}
export -f hardenUserdata;

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
}
export -f getDefconfig;

changeDefaultDNS() {
	dnsPrimary="";
	dnsPrimaryV6="";
	dnsSecondary="";
	dnsSecondaryV6="";
	if [ -z "$DNS_PRESET" ]; then
		if [[ "$DOS_DEFAULT_DNS_PRESET" == "CensurfriDNS" ]]; then #https://uncensoreddns.org
			dnsPrimary="91.239.100.100";
			dnsPrimaryV6="2001:67c:28a4::";
			dnsSecondary="89.233.43.71";
			dnsSecondaryV6="2a01:3a0:53:53::";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "Cloudflare" ]]; then #https://developers.cloudflare.com/1.1.1.1/commitment-to-privacy/privacy-policy/privacy-policy
			dnsPrimary="1.0.0.1";
			dnsPrimaryV6="2606:4700:4700::1001";
			dnsSecondary="1.1.1.1";
			dnsSecondaryV6="2606:4700:4700::1111";
		elif [[ "$DOS_DEFAULT_DNS_PRESET" == "OpenNIC" ]]; then #https://servers.opennicproject.org/edit.php?srv=ns3.any.dns.opennic.glue
			dnsPrimary="169.239.202.202";
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
	declare -a optionsYes=("CONFIG_ARM64_SW_TTBR0_PAN" "CONFIG_BUG" "CONFIG_BUG_ON_DATA_CORRUPTION" "CONFIG_CC_STACKPROTECTOR" "CONFIG_CC_STACKPROTECTOR_STRONG" "CONFIG_STACKPROTECTOR" "CONFIG_STACKPROTECTOR_STRONG" "CONFIG_CPU_SW_DOMAIN_PAN" "CONFIG_DEBUG_CREDENTIALS" "CONFIG_DEBUG_KERNEL" "CONFIG_DEBUG_LIST" "CONFIG_DEBUG_NOTIFIERS" "CONFIG_DEBUG_RODATA" "CONFIG_DEBUG_WX" "CONFIG_FORTIFY_SOURCE" "CONFIG_GCC_PLUGIN_LATENT_ENTROPY" "CONFIG_GCC_PLUGIN_RANDSTRUCT" "CONFIG_GCC_PLUGINS" "CONFIG_GCC_PLUGIN_STRUCTLEAK" "CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL" "CONFIG_HARDENED_USERCOPY" "CONFIG_IO_STRICT_DEVMEM" "CONFIG_KAISER" "CONFIG_LEGACY_VSYSCALL_NONE" "CONFIG_PAGE_POISONING" "CONFIG_PAGE_POISONING_NO_SANITY" "CONFIG_PAGE_POISONING_ZERO" "CONFIG_PAGE_TABLE_ISOLATION" "CONFIG_PANIC_ON_OOPS" "CONFIG_RANDOMIZE_BASE" "CONFIG_REFCOUNT_FULL" "CONFIG_RETPOLINE" "CONFIG_SCHED_STACK_END_CHECK" "CONFIG_SECCOMP" "CONFIG_SECCOMP_FILTER" "CONFIG_SECURITY" "CONFIG_SECURITY_PERF_EVENTS_RESTRICT" "CONFIG_SECURITY_YAMA" "CONFIG_SECURITY_YAMA_STACKED" "CONFIG_SLAB_FREELIST_RANDOM" "CONFIG_SLAB_HARDENED" "CONFIG_SLUB_DEBUG" "CONFIG_STRICT_DEVMEM" "CONFIG_STRICT_KERNEL_RWX" "CONFIG_STRICT_MEMORY_RWX" "CONFIG_SYN_COOKIES" "CONFIG_UNMAP_KERNEL_AT_EL0" "CONFIG_VMAP_STACK" "CONFIG_SECURITY_DMESG_RESTRICT" "CONFIG_SLAB_FREELIST_HARDENED" "CONFIG_GCC_PLUGINS" "CONFIG_GCC_PLUGIN_LATENT_ENTROPY" "CONFIG_GCC_PLUGIN_STRUCTLEAK" "CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL" "CONFIG_GCC_PLUGIN_RANDSTRUCT" "CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE" "CONFIG_IPV6_PRIVACY" "CONFIG_HARDEN_BRANCH_PREDICTOR" "CONFIG_IOMMU_API" "CONFIG_IOMMU_SUPPORT" "CONFIG_IOMMU_HELPER" "CONFIG_INTEL_IOMMU_DEFAULT_ON" "CONFIG_ARM_SMMU" "CONFIG_QCOM_IOMMU" "CONFIG_MSM_IOMMU" "CONFIG_MSM_TZ_SMMU" "CONFIG_KGSL_PER_PROCESS_PAGE_TABLE" "CONFIG_MSM_KGSL_MMU_PAGE_FAULT" "CONFIG_IOMMU_PGTABLES_L2" "CONFIG_TEGRA_IOMMU_SMMU" "CONFIG_TEGRA_IOMMU_GART" "CONFIG_MTK_IOMMU" "CONFIG_EXYNOS_IOMMU" "CONFIG_OMAP_IOMMU" "CONFIG_OF_IOMMU")
	for option in "${optionsYes[@]}"
	do
		sed -i 's/# '"$option"' is not set/'"$option"'=y/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ "$defconfigPath" == *"lineage"* ]]; then
			if ! grep -q "$option=y" $defconfigPath; then
				echo "$option=y" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
	done
	#Disable supported options
	declare -a optionsNo=("CONFIG_ACPI_CUSTOM_METHOD" "CONFIG_BINFMT_MISC" "CONFIG_COMPAT_BRK" "CONFIG_COMPAT_VDSO" "CONFIG_CP_ACCESS64" "CONFIG_DEVKMEM" "CONFIG_DEVMEM" "CONFIG_DEVPORT" "CONFIG_HIBERNATION" "CONFIG_INET_DIAG" "CONFIG_KEXEC" "CONFIG_LEGACY_PTYS" "CONFIG_MSM_BUSPM_DEV" "CONFIG_OABI_COMPAT" "CONFIG_PROC_KCORE" "CONFIG_PROC_VMCORE" "CONFIG_SECURITY_SELINUX_DISABLE" "CONFIG_SLAB_MERGE_DEFAULT" "CONFIG_WLAN_FEATURE_MEMDUMP" "CONFIG_EARJACK_DEBUGGER" "CONFIG_IOMMU_NON_SECURE" "CONFIG_MSM_DLOAD_MODE");
	if [[ "$1" != *"kernel/htc/msm8994"* ]] && [[ "$1" != *"kernel/samsung/smdk4412"* ]] && [[ "$1" != *"kernel/htc/flounder"* ]]; then
		optionsNo+=("CONFIG_DIAG_CHAR" "CONFIG_DIAG_OVER_USB" "CONFIG_USB_QCOM_DIAG_BRIDGE" "CONFIG_DIAGFWD_BRIDGE_CODE" "CONFIG_DIAG_SDIO_PIPE" "CONFIG_DIAG_HSIC_PIPE");
	fi;
	if [ "$DOS_DEBLOBBER_REMOVE_IPA" = true ]; then optionsNo+=("CONFIG_IPA"); fi;
	for option in "${optionsNo[@]}"
	do
		sed -i 's/'"$option"'=y/# '"$option"' is not set/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ "$defconfigPath" == *"lineage"* ]]; then
			if ! grep -q "$option=n" $defconfigPath; then
				echo "$option=n" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
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
