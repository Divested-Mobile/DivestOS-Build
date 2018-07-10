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

#Changes various default settings
#Last verified: 2018-07-10

#Useful commands
#nano $(find . -name "config.xml" | grep "values/" | grep -v "device" | grep -v "tests")
#nano $(find . -name "defaults.xml" | grep "values/" | grep -v "device")

echo "Changing default settings...";

enter "frameworks/base";
sed -i 's/def_lockscreen_sounds_enabled">1/def_lockscreen_sounds_enabled">0/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_networks_available_notification_on">true/def_networks_available_notification_on">false/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_sound_effects_enabled">true/def_sound_effects_enabled">false/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/_animation_scale">100%/_animation_scale">50%/' packages/SettingsProvider/res/values/defaults.xml;

enter "packages/apps/Dialer";
sed -i 's/ENABLE_FORWARD_LOOKUP, 1)/ENABLE_FORWARD_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java; #Disable FLP
sed -i 's/ENABLE_PEOPLE_LOOKUP, 1)/ENABLE_PEOPLE_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java; #Disable PLP
sed -i 's/ENABLE_REVERSE_LOOKUP, 1)/ENABLE_REVERSE_LOOKUP, 0)/' src/com/android/dialer/*/LookupSettings*.java; #Disable RLP

enter "packages/apps/FDroid";
sed -i '/string\/show_root_apps/!b;n;s/defaultValue="true"/defaultValue="false"/' app/src/main/res/xml/preferences.xml;
sed -i '/string\/show_anti_feature_apps/!b;n;s/defaultValue="true"/defaultValue="false"/' app/src/main/res/xml/preferences.xml;

enter "packages/apps/Nfc";
sed -i 's/boolean NFC_ON_DEFAULT = true;/boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/boolean NDEF_PUSH_ON_DEFAULT = true;/boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push

enter "packages/apps/Settings";
sed -i 's/Float.parseFloat(newValue.toString()) : 1;/Float.parseFloat(newValue.toString()) : 0.5f;/' src/com/android/settings/DevelopmentSettings.java; #Always reset animation scales to 0.5

enter "packages/apps/Trebuchet";
sed -i 's|homescreen_search_default">true|homescreen_search_default">false|' res/values/preferences_defaults.xml; #Disable search

enter "vendor/cm";
sed -i 's/ro.config.notification_sound=Argon.ogg/ro.config.notification_sound=Pong.ogg/' config/common*.mk;
sed -i 's/ro.config.alarm_alert=Hassium.ogg/ro.config.alarm_alert=Alarm_Buzzer.ogg/' config/common*.mk;
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml;
sed -i 's|config_mms_user_agent">LineageOS|config_mms_user_agent">Android-Mms/2.0|' overlay/common/frameworks/base/core/res/res/values/config.xml;

cd "$DOS_BUILD_BASE";
echo "Default settings changed!";
