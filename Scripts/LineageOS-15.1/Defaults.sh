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

echo "Changing default settings..."

enter "frameworks/base"
sed -i '0,/wifi,cell,battery/s/wifi,cell,battery,dnd,flashlight,rotation,bt,airplane/wifi,cell,bt,dnd,flashlight,rotation,battery,profiles,location,airplane,saver,hotspot,nfc/' packages/SystemUI/res/values/config.xml; #Default quick tiles
#sed -i 's|config_longPressOnHomeBehavior">2|config_longPressOnHomeBehavior">0|' core/res/res/values/config.xml; #Set long press home to do nothing
#sed -i 's|config_doubleTapOnHomeBehavior">0|config_doubleTapOnHomeBehavior">8|' core/res/res/values/config.xml; #Set double tap home to switch to last app

enter "packages/apps/Dialer"
sed -i 's/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 1)/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings.java; #Disable FLP
sed -i 's/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 1)/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings.java; #Disable PLP
sed -i 's/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 1)/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettings.java; #Disable RLP
sed -i 's/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 1)/LineageSettings.System.ENABLE_FORWARD_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettingsFragment.java; #Disable FLP
sed -i 's/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 1)/LineageSettings.System.ENABLE_PEOPLE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettingsFragment.java; #Disable PLP
sed -i 's/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 1)/LineageSettings.System.ENABLE_REVERSE_LOOKUP, 0)/' java/com/android/dialer/lookup/LookupSettingsFragment.java; #Disable RLP

enter "packages/apps/FDroid"
sed -i 's|DEFAULT_ROOTED = true;|DEFAULT_ROOTED = false;|' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide root apps
sed -i '/string\/rooted/!b;n;s/defaultValue="true"/defaultValue="false"/' app/src/main/res/xml/preferences.xml;
sed -i 's|DEFAULT_HIDE_ANTI_FEATURE_APPS = false;|DEFAULT_HIDE_ANTI_FEATURE_APPS = true;|' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide anti-feature apps
sed -i '/string\/hide_anti_feature_apps/!b;n;s/defaultValue="false"/defaultValue="true"/' app/src/main/res/xml/preferences.xml;

enter "packages/apps/Nfc"
sed -i 's/static final boolean NFC_ON_DEFAULT = true;/static final boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/static final boolean NDEF_PUSH_ON_DEFAULT = true;/static final boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push

enter "packages/apps/Settings"
sed -i 's/Settings.Secure.INSTANT_APPS_ENABLED, 1/Settings.Secure.INSTANT_APPS_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java; #Disable "Instant Apps"
sed -i 's/Float.parseFloat(newValue.toString()) : 1;/Float.parseFloat(newValue.toString()) : 0.5f;/' src/com/android/settings/development/DevelopmentSettings.java; #Always reset animation scales to 0.5

cd $base
echo "Default settings changed!"
