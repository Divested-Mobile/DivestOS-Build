#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017 Spot Communications, Inc.
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

enter() {
	echo "================================================================================================"
	dir=$1;
	cd $base$dir;
	echo "[ENTERING] "$dir;
}
export -f enter;

enterAndClear() {
	enter $1;
	gitReset;
}
export -f enterAndClear;

gitReset() {
	git add -A && git reset --hard;
}
export -f gitReset;

enableDexPreOpt() {
	echo "WITH_DEXPREOPT := true" >> BoardConfig.mk;
	echo "WITH_DEXPREOPT_PIC := true" >> BoardConfig.mk;
	echo "Enabled dexpreopt";
}
export -f enableDexPreOpt;

disableDexPreOpt() {
	sed -i 's/WITH_DEXPREOPT := true/WITH_DEXPREOPT := false/' BoardConfig.mk;
	sed -i 's/WITH_DEXPREOPT_PIC := true/WITH_DEXPREOPT_PIC := false/' BoardConfig.mk;
	echo "Disabled dexpreopt";
}
export -f disableDexPreOpt;

enhanceLocation() {
	cd $base$1;
	#Enable GLONASS
	#sed -i 's/#A_GLONASS_POS_PROTOCOL_SELECT/A_GLONASS_POS_PROTOCOL_SELECT/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#sed -i 's/A_GLONASS_POS_PROTOCOL_SELECT = 0.*/A_GLONASS_POS_PROTOCOL_SELECT = 15/' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#sed -i 's|A_GLONASS_POS_PROTOCOL_SELECT=0.*</item>|A_GLONASS_POS_PROTOCOL_SELECT=15</item>|' overlay/frameworks/base/core/res/res/values-*/*.xml &>/dev/null || true;
	#Recommended reading: https://wwws.nightwatchcybersecurity.com/2016/12/05/cve-2016-5341/
	#XTRA: Only use specified URLs
	sed -i 's|XTRA_SERVER_QUERY=1|XTRA_SERVER_QUERY=0|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	sed -i 's|#XTRA_SERVER|XTRA_SERVER|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Enable HTTPS
	sed -i 's|http://xtra|https://xtra|' overlay/frameworks/base/core/res/res/values-*/*.xml gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	#XTRA: Use format version 3 if possible
	if grep -sq "XTRA_VERSION_CHECK" gps.conf gps/gps.conf configs/gps.conf; then #Using hardware/qcom/gps OR precompiled blob OR device specific implementation
		sed -i 's|XTRA_VERSION_CHECK=0|XTRA_VERSION_CHECK=1|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
		sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
	elif grep -sq "BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true" BoardConfig.mk boards/*gps.mk; then
		if ! grep -sq "USE_DEVICE_SPECIFIC_LOC_API := true" BoardConfig.mk boards/*gps.mk; then
			if ! grep -sq "libloc" *proprietary*.txt; then #Using hardware/qcom/gps
				sed -i 's|xtra2.bin|xtra3grc.bin|' gps.conf gps/gps.conf configs/gps.conf &>/dev/null || true;
			fi;
		fi;
	fi;
	echo "Enhanced location services for $1";
	cd $base;
}
export -f enhanceLocation;

enableZram() {
	cd $base$1;
	sed -i 's|#/dev/block/zram0|/dev/block/zram0|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
	echo "Enabled zram for $1";
	cd $base;
}
export -f enableZram;

enableForcedEncryption() {
	cd $base$1;
	if [[ $1 != *"mako"* ]]; then #Forced encryption seems to prevent some devices from booting
		sed -i 's|encryptable=/|forceencrypt=/|' fstab.* root/fstab.* rootdir/fstab.* rootdir/etc/fstab.* &>/dev/null || true;
		echo "Enabled forceencrypt for $1";
	fi;
	cd $base;
}
export -f enableForcedEncryption;

enableStrongEncryption() {
	cd $base$1;
		echo "TARGET_WANTS_STRONG_ENCRYPTION := true" >> BoardConfig.mk;
		echo "Enabled AES-256 encryption for $1";
	cd $base;
}
export -f enableStrongEncryption;

hardenDefconfig() {
	cd $base$1;

	#Attempts to enable/disable supported options to increase security
	#See https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Recommended_Settings

	if ls arch/arm/configs/lineage*defconfig 1> /dev/null 2>&1; then
		defconfigPath="arch/arm/configs/lineage*defconfig";
	elif ls arch/arm64/configs/lineage*defconfig 1> /dev/null 2>&1; then
		defconfigPath="arch/arm64/configs/lineage*defconfig";
	else
		defconfigPath="arch/arm/configs/*defconfig arch/arm64/configs/*defconfig";
	fi;
	#echo "Found defconfig at $defconfigPath"

	#Enable supported options
	#Disabled: CONFIG_DEBUG_SG (bootloops - https://patchwork.kernel.org/patch/8989981)
	declare -a optionsYes=("CONFIG_ARM64_SW_TTBR0_PAN" "CONFIG_BUG_ON_DATA_CORRUPTION" "CONFIG_BUG" "CONFIG_CC_STACKPROTECTOR_STRONG" "CONFIG_CC_STACKPROTECTOR" "CONFIG_CPU_SW_DOMAIN_PAN" "CONFIG_DEBUG_CREDENTIALS" "CONFIG_DEBUG_KERNEL" "CONFIG_DEBUG_LIST" "CONFIG_DEBUG_NOTIFIERS" "CONFIG_DEBUG_RODATA" "CONFIG_DEBUG_WX" "CONFIG_FORTIFY_SOURCE" "CONFIG_GCC_PLUGIN_LATENT_ENTROPY" "CONFIG_GCC_PLUGIN_RANDSTRUCT" "CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL" "CONFIG_GCC_PLUGIN_STRUCTLEAK" "CONFIG_GCC_PLUGINS" "CONFIG_HARDENED_USERCOPY" "CONFIG_IO_STRICT_DEVMEM" "CONFIG_LEGACY_VSYSCALL_NONE" "CONFIG_PAGE_POISONING_NO_SANITY" "CONFIG_PAGE_POISONING" "CONFIG_PAGE_POISONING_ZERO" "CONFIG_PANIC_ON_OOPS" "CONFIG_RANDOMIZE_BASE" "CONFIG_REFCOUNT_FULL" "CONFIG_SCHED_STACK_END_CHECK" "CONFIG_SECCOMP_FILTER" "CONFIG_SECCOMP" "CONFIG_SECURITY" "CONFIG_SECURITY_YAMA" "CONFIG_SECURITY_YAMA_STACKED" "CONFIG_SLAB_FREELIST_RANDOM" "CONFIG_SLAB_HARDENED" "CONFIG_SLUB_DEBUG" "CONFIG_STRICT_DEVMEM" "CONFIG_STRICT_KERNEL_RWX" "CONFIG_STRICT_MEMORY_RWX" "CONFIG_SYN_COOKIES" "CONFIG_VMAP_STACK" "CONFIG_SECURITY_PERF_EVENTS_RESTRICT")
	for option in "${optionsYes[@]}"
	do
		sed -i 's/# '$option' is not set/'$option'=y/' $defconfigPath &>/dev/null || true;
		#Some defconfigs are very minimal/not-autogenerated, so lets add the rest. Obviously most won't have any affect as they aren't supported.
		if [[ $defconfigPath == *"lineage"* ]]; then
			if ! grep -q $option"=y" $defconfigPath; then
				echo $option"=y" | tee -a $defconfigPath > /dev/null;
			fi;
		fi;
	done
	#Disable supported options
	declare -a optionsNo=("CONFIG_SECURITY_SELINUX_DISABLE" "CONFIG_PROC_KCORE" "CONFIG_OABI_COMPAT" "CONFIG_KEXEC" "CONFIG_LEGACY_PTYS" "CONFIG_HIBERNATION" "CONFIG_INET_DIAG" "CONFIG_DEVKMEM" "CONFIG_DEVMEM" "CONFIG_COMPAT_BRK" "CONFIG_COMPAT_VDSO" "CONFIG_BINFMT_MISC" "CONFIG_ACPI_CUSTOM_METHOD" "CONFIG_MSM_BUSPM_DEV" "CONFIG_CP_ACCESS64")
	for option in "${optionsNo[@]}"
	do
		sed -i 's/'$option'=y/# '$option' is not set/' $defconfigPath &>/dev/null || true;
	done
	#Extras
	sed -i 's/CONFIG_DEFAULT_MMAP_MIN_ADDR=4096/CONFIG_DEFAULT_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;
	sed -i 's/CONFIG_LSM_MMAP_MIN_ADDR=4096/CONFIG_DEFAULT_MMAP_MIN_ADDR=32768/' $defconfigPath &>/dev/null || true;

	echo "Hardened defconfig for $1";
	cd $base;
}
export -f hardenDefconfig;
