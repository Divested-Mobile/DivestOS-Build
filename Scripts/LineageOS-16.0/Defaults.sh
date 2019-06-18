#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing Group
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

#Changes various default settings
#Last verified: 2019-03-04

#Useful commands
#nano $(find . -name "config.xml" | grep "values/" | grep -v "device" | grep -v "tests")
#nano $(find . -name "defaults.xml" | grep "values/" | grep -v "device")

echo "Changing default settings...";

enter "packages/apps/Dialer";
sed -i 's/ENABLE_FORWARD_LOOKUP, 1)/ENABLE_FORWARD_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, 1)/ENABLE_PEOPLE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, 1)/ENABLE_REVERSE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable RLP

enter "packages/apps/Nfc";
sed -i 's/boolean NFC_ON_DEFAULT = true;/boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/boolean NDEF_PUSH_ON_DEFAULT = true;/boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push

enter "packages/apps/Settings";
sed -i 's/INSTANT_APPS_ENABLED, 1/INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java; #Disable "Instant Apps"
sed -i 's/DEFAULT_VALUE = 1;/DEFAULT_VALUE = 0.5f;/' src/com/android/settings/development/*ScalePreferenceController.java; #Always reset animation scales to 0.5

enter "vendor/lineage";
sed -i 's/ro.config.notification_sound=Argon.ogg/ro.config.notification_sound=Pong.ogg/' config/common.mk;
sed -i 's/ro.config.alarm_alert=Hassium.ogg/ro.config.alarm_alert=Alarm_Buzzer.ogg/' config/common.mk;

cd "$DOS_BUILD_BASE";
echo "Default settings changed!";
