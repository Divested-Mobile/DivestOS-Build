#!/bin/sh
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2022 Divested Computing Group
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

#APN List
wget "https://github.com/LineageOS/android_vendor_lineage/raw/lineage-20.0/prebuilt/common/etc/apns-conf.xml" -O ../Patches/Common/apns-conf.xml;

#Visual VoiceMail Config
#wget "https://raw.githubusercontent.com/LineageOS/android_vendor_lineage/lineage-19.1/overlay/common/packages/apps/Dialer/java/com/android/voicemail/impl/res/xml/vvm_config.xml" -O ../Patches/./Common/android_vendor_divested/overlay/common/packages/apps/Dialer/java/com/android/voicemail/impl/res/xml/vvm_config.xml;
wget "https://raw.githubusercontent.com/GrapheneOS/platform_packages_apps_Dialer/13/java/com/android/voicemail/impl/res/xml/vvm_config.xml" -O ../Patches/./Common/android_vendor_divested/overlay/common/packages/apps/Dialer/java/com/android/voicemail/impl/res/xml/vvm_config.xml;

#LineageOS Contributors Cloud
wget "https://github.com/LineageOS/android_packages_apps_LineageParts/raw/lineage-19.1/assets/contributors.db" -O ../Patches/Common/contributors.db;

#TODO: wireless-regdb
#https://mirrors.edge.kernel.org/pub/software/network/wireless-regdb/
#Last: 2022/12/15

#TODO: MMS Configs
#https://github.com/GrapheneOS/platform_packages_apps_Messaging
#Last: 2022/12/15

#TODO: Carrier List
#https://android.googlesource.com/platform/packages/providers/TelephonyProvider/
#Last: 2022/10/12

#TODO: Carrier Configs
#https://android.googlesource.com/platform/packages/apps/CarrierConfig/
#Last: 2022/10/12
