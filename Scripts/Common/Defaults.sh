#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2017-2023 Divested Computing Group
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
#Last verified: 2022-10-15

#Useful commands
#nano $(find . -name "config.xml" | grep "values/" | grep -v "device" | grep -v "tests")
#nano $(find . -name "defaults.xml" | grep "values/" | grep -v "device")

echo "Changing default settings...";

if enter "frameworks/base"; then
sed -i 's/KEY_SHOW_APN_SETTING_CDMA_BOOL, false);/KEY_SHOW_APN_SETTING_CDMA_BOOL, true);/' telephony/java/android/telephony/CarrierConfigManager.java &>/dev/null || true; #Always show APN settings on CDMA carriers (GrapheneOS)
sed -i 's/KEY_READ_ONLY_APN_TYPES_STRING_ARRAY, new String\[\] {"dun"})/KEY_READ_ONLY_APN_TYPES_STRING_ARRAY, new String\[\] {""});/' telephony/java/android/telephony/CarrierConfigManager.java &>/dev/null || true; #Do not mark dun APN types as read only (GrapheneOS)
sed -i 's/KEY_SHOW_ICCID_IN_SIM_STATUS_BOOL, false);/KEY_SHOW_ICCID_IN_SIM_STATUS_BOOL, true);/' telephony/java/android/telephony/CarrierConfigManager.java &>/dev/null || true; #Always show ICCID (GrapheneOS)
#14.1
#sed -i 's/CMPRIVACY_GUARD_NOTIFICATION, 1/CMPRIVACY_GUARD_NOTIFICATION, 0/' services/core/java/com/android/server/am/ActivityStack.java &>/dev/null || true;
#sed -i 's/VOLBTN_MUSIC_CONTROLS, 1/VOLBTN_MUSIC_CONTROLS, 0/' services/core/java/com/android/server/policy/PhoneWindowManager.java &>/dev/null || true; #FIXME
#sed -i 's/VOLUME_KEYS_CONTROL_RING_STREAM, 1/VOLUME_KEYS_CONTROL_RING_STREAM, 0/' services/core/java/com/android/server/audio/AudioService.java &>/dev/null || true; #FIXME
#sed -i 's/TORCH_LONG_PRESS_POWER_GESTURE, 0/TORCH_LONG_PRESS_POWER_GESTURE, 1/' services/core/java/com/android/server/policy/PhoneWindowManager.java &>/dev/null || true; #FIXME
#sed -i 's/TORCH_LONG_PRESS_POWER_TIMEOUT, 0/TORCH_LONG_PRESS_POWER_TIMEOUT, 120/' services/core/java/com/android/server/policy/PhoneWindowManager.java &>/dev/null || true; #FIXME
#sed -i 's/CAMERA_DOUBLE_TAP_POWER_GESTURE_DISABLED, 0/CAMERA_DOUBLE_TAP_POWER_GESTURE_DISABLED, 1/' services/core/java/com/android/server/GestureLauncherService.java &>/dev/null || true; #FIXME
#sed -i 's/NAVIGATION_BAR_MENU_ARROW_KEYS, 0/NAVIGATION_BAR_MENU_ARROW_KEYS, 1/' packages/SystemUI/src/com/android/systemui/statusbar/phone/NavigationBarView.java &>/dev/null || true; #FIXME
fi;

if enter "packages/apps/Dialer"; then
#14.1
sed -i 's/ENABLE_FORWARD_LOOKUP, 1)/ENABLE_FORWARD_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java &>/dev/null || true; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, 1)/ENABLE_PEOPLE_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java &>/dev/null || true; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, 1)/ENABLE_REVERSE_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java &>/dev/null || true; #Disable RLP
#15.1+16.0+17.1
sed -i 's/ENABLE_FORWARD_LOOKUP, 1)/ENABLE_FORWARD_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, 1)/ENABLE_PEOPLE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, 1)/ENABLE_REVERSE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable RLP
#18.1+
sed -i 's/ENABLE_FORWARD_LOOKUP, true)/ENABLE_FORWARD_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, true)/ENABLE_PEOPLE_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, true)/ENABLE_REVERSE_LOOKUP, false)/' java/com/android/dialer/lookup/LookupSettings*.java &>/dev/null || true; #Disable RLP
fi;

if enter "packages/apps/Nfc"; then
sed -i 's/boolean NFC_ON_DEFAULT = true;/boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java &>/dev/null || true; #Disable NFC
sed -i 's/boolean NDEF_PUSH_ON_DEFAULT = true;/boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java &>/dev/null || true; #Disable NDEF Push
fi;

if enter "packages/apps/Settings"; then
#Disable "Instant Apps"
sed -i 's/WEB_ACTION_ENABLED, 1/WEB_ACTION_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java &>/dev/null || true; #14.1
sed -i 's/INSTANT_APPS_ENABLED, 1/INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java &>/dev/null || true; #15.1+16.0
sed -i 's/INSTANT_APPS_ENABLED, 1/INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/managedomainurls/InstantAppWebActionPreferenceController.java &>/dev/null || true; #17.1+
#Always reset animation scales to 0.5
sed -i 's/Float.parseFloat(newValue.toString()) : 1;/Float.parseFloat(newValue.toString()) : 0.5f;/' src/com/android/settings/DevelopmentSettings.java &>/dev/null || true; #14.1
sed -i 's/Float.parseFloat(newValue.toString()) : 1;/Float.parseFloat(newValue.toString()) : 0.5f;/' src/com/android/settings/development/DevelopmentSettings.java &>/dev/null || true; #15.1
sed -i 's/DEFAULT_VALUE = 1;/DEFAULT_VALUE = 0.5f;/' src/com/android/settings/development/*ScalePreferenceController.java &>/dev/null || true; #16.0+
fi;

if enter "packages/apps/SetupWizard"; then
sed -i 's/UPDATE_RECOVERY_PROP, false)/UPDATE_RECOVERY_PROP, true)/' src/org/lineageos/setupwizard/UpdateRecoveryActivity.java &>/dev/null || true; #Always update recovery by default 18.1+
fi;

if enter "packages/apps/Trebuchet"; then
sed -i 's/"pref_predictive_apps", true/"pref_predictive_apps", false/' src/com/android/launcher3/Launcher.java &>/dev/null || true; #15.1
fi;

if enter "packages/apps/Updater"; then
sed -i 's/Constants.UPDATE_RECOVERY_PROPERTY, false)/Constants.UPDATE_RECOVERY_PROPERTY, true)/' src/org/lineageos/updater/UpdatesActivity.java &>/dev/null || true; #Always update recovery by default 18.1+
fi;

if [[ "$DOS_VERSION" == "LineageOS-14.1" ]]; then

if enter "vendor/cm"; then #14.1
sed -i 's/ro.config.notification_sound=Argon.ogg/ro.config.notification_sound=Pong.ogg/' config/common*.mk &>/dev/null || true;
sed -i 's/ro.config.alarm_alert=Hassium.ogg/ro.config.alarm_alert=Alarm_Buzzer.ogg/' config/common*.mk &>/dev/null || true;
fi;

else

if enter "vendor/lineage"; then #15.1+
sed -i 's/ro.config.notification_sound=Argon.ogg/ro.config.notification_sound=Pong.ogg/' config/common*.mk &>/dev/null || true;
sed -i 's/ro.config.alarm_alert=Hassium.ogg/ro.config.alarm_alert=Alarm_Buzzer.ogg/' config/common*.mk &>/dev/null || true;
fi;

fi;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Default settings changed\e[0m";
