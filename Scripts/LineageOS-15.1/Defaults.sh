#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Spot Communications, Inc.
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

#Useful commands
#nano $(find . -name "config.xml" | grep "values/" | grep -v "device" | grep -v "tests")
#nano $(find . -name "defaults.xml" | grep "values/" | grep -v "device")

echo "Changing default settings...";

enter "lineage-sdk";
sed -i 's/config_doubleTapOnHomeBehavior">0/config_doubleTapOnHomeBehavior">8/' lineage/res/res/values/config.xml;
sed -i 's/def_forward_lookup">1/def_forward_lookup">0/' packages/LineageSettingsProvider/res/values/defaults.xml;
sed -i 's/def_people_lookup">1/def_people_lookup">0/' packages/LineageSettingsProvider/res/values/defaults.xml;
sed -i 's/def_reverse_lookup">1/def_reverse_lookup">0/' packages/LineageSettingsProvider/res/values/defaults.xml;

enter "frameworks/base";
sed -i '0,/wifi,bt,dnd,flashlight/s/wifi,bt,dnd,flashlight,rotation,battery,cell,airplane,cast/wifi,cell,bt,dnd,flashlight,rotation,battery,sync,location,airplane,saver,hotspot,nfc/' packages/SystemUI/res/values/config.xml; #Default quick tiles
sed -i 's/def_lock_screen_allow_private_notifications">true/def_lock_screen_allow_private_notifications">false/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_lockscreen_sounds_enabled">1/def_lockscreen_sounds_enabled">0/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_networks_available_notification_on">true/def_networks_available_notification_on">false/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_sound_effects_enabled">true/def_sound_effects_enabled">false/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_window_animation_scale">100%/def_window_animation_scale">50%/' packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/def_window_transition_scale">100%/def_window_transition_scale">50%/' packages/SettingsProvider/res/values/defaults.xml;
#sed -i 's/LineageSettings.Secure.PRIVACY_GUARD_NOTIFICATION, 1/LineageSettings.Secure.PRIVACY_GUARD_NOTIFICATION, 0/' services/core/java/com/android/server/am/ActivityRecord.java;

enter "packages/apps/Dialer";
sed -i 's/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 1)/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable FLP
sed -i 's/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 1)/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable PLP
sed -i 's/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 1)/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings*.java; #Disable RLP

enter "packages/apps/FDroid";
sed -i 's/DEFAULT_ROOTED = true;/DEFAULT_ROOTED = false;/' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide root apps
sed -i '/string\/rooted/!b;n;s/defaultValue="true"/defaultValue="false"/' app/src/main/res/xml/preferences.xml;
sed -i 's/DEFAULT_HIDE_ANTI_FEATURE_APPS = false;/DEFAULT_HIDE_ANTI_FEATURE_APPS = true;/' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide anti-feature apps
sed -i '/string\/hide_anti_feature_apps/!b;n;s/defaultValue="false"/defaultValue="true"/' app/src/main/res/xml/preferences.xml;

enter "packages/apps/Nfc";
sed -i 's/static final boolean NFC_ON_DEFAULT = true;/static final boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/static final boolean NDEF_PUSH_ON_DEFAULT = true;/static final boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push

enter "packages/apps/Settings";
sed -i 's/Settings.Secure.INSTANT_APPS_ENABLED, 1/Settings.Secure.INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java; #Disable "Instant Apps"
sed -i 's/Float.parseFloat(newValue.toString()) : 1;/Float.parseFloat(newValue.toString()) : 0.5f;/' src/com/android/settings/development/DevelopmentSettings.java; #Always reset animation scales to 0.5

enter "packages/apps/Trebuchet";
sed -i 's/"pref_predictive_apps", true/"pref_predictive_apps", false/' src/com/android/launcher3/Launcher.java;

enter "packages/inputmethods/LatinIME";
sed -i 's/config_personalization_dict_wipe_interval_in_days">-1/config_personalization_dict_wipe_interval_in_days">5/' java/res/values/config-common.xml;
sed -i 's/PREF_KEY_USE_PERSONALIZED_DICTS, true/PREF_KEY_USE_PERSONALIZED_DICTS, false/' java/src/com/android/inputmethod/latin/settings/SettingsValues.java;

enter "vendor/lineage";
awk -i inplace '!/def_backup_transport/' overlay/common/frameworks/base/packages/SettingsProvider/res/values/defaults.xml;
sed -i 's/config_mms_user_agent">LineageOS/config_mms_user_agent">Android-Mms/2.0/' overlay/common/frameworks/base/core/res/res/values/config.xml;
sed -i 's/def_stats_collection">true/def_stats_collection">false/' overlay/common/lineage-sdk/packages/LineageSettingsProvider/res/values/defaults.xml;
sed -i 's/config_storage_manager_settings_enabled">true/config_storage_manager_settings_enabled">false/' overlay/common/packages/apps/Settings/res/values/config.xml;
sed -i 's/config_enableRecoveryUpdater">false/config_enableRecoveryUpdater">true/' overlay/common/packages/apps/Settings/res/values/config.xml;

cd $base;
echo "Default settings changed!";
