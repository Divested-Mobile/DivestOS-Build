#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2021 Divested Computing Group
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
set -euo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

#Changes various default settings
#Last verified: 2022-04-04

#Useful commands
#nano $(find . -name "config.xml" | grep "values/" | grep -v "device" | grep -v "tests")
#nano $(find . -name "defaults.xml" | grep "values/" | grep -v "device")

echo "Changing default settings...";

if enter "packages/apps/Dialer"; then
sed -i 's/ENABLE_FORWARD_LOOKUP, true)/ENABLE_FORWARD_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, true)/ENABLE_PEOPLE_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, true)/ENABLE_REVERSE_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable RLP
fi;

if enter "packages/apps/Nfc"; then
sed -i 's/boolean NFC_ON_DEFAULT = true;/boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/boolean NDEF_PUSH_ON_DEFAULT = true;/boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push
fi;

if enter "packages/apps/Settings"; then
sed -i 's/INSTANT_APPS_ENABLED, 1/INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/managedomainurls/InstantAppWebActionPreferenceController.java; #Disable "Instant Apps"
sed -i 's/DEFAULT_VALUE = 1;/DEFAULT_VALUE = 0.5f;/' src/com/android/settings/development/*ScalePreferenceController.java; #Always reset animation scales to 0.5
fi;

if enter "packages/apps/SetupWizard"; then
sed -i 's/UPDATE_RECOVERY_PROP, false)/UPDATE_RECOVERY_PROP, true)/' src/org/lineageos/setupwizard/UpdateRecoveryActivity.java; #Always update recovery by default
fi;

if enter "packages/apps/Updater"; then
sed -i 's/Constants.UPDATE_RECOVERY_PROPERTY, false)/Constants.UPDATE_RECOVERY_PROPERTY, true)/' src/org/lineageos/updater/UpdatesActivity.java; #Always update recovery by default
fi;

if enter "vendor/lineage"; then
sed -i 's/ro.config.notification_sound=Argon.ogg/ro.config.notification_sound=Pong.ogg/' config/common*.mk;
sed -i 's/ro.config.alarm_alert=Hassium.ogg/ro.config.alarm_alert=Alarm_Buzzer.ogg/' config/common*.mk;
fi;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Default settings changed\e[0m";
