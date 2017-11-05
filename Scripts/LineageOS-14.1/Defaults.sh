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

#Changes various default settings

echo "Changing default settings..."

cd $base"frameworks/base"
sed -i '0,/wifi,cell,battery/s/wifi,cell,battery,dnd,flashlight,rotation,bt,airplane/wifi,cell,bt,dnd,flashlight,rotation,battery,profiles,location,airplane,saver,hotspot,nfc/' packages/SystemUI/res/values/config.xml; #Default quick tiles
sed -i 's|config_longPressOnHomeBehavior">2|config_longPressOnHomeBehavior">0|' core/res/res/values/config.xml; #Set long press home to do nothing
sed -i 's|config_doubleTapOnHomeBehavior">0|config_doubleTapOnHomeBehavior">8|' core/res/res/values/config.xml; #Set double tap home to switch to last app

cd $base"packages/apps/Dialer"
sed -i 's/FLP_DEFAULT = FLP_GOOGLE;/FLP_DEFAULT = FLP_OPENSTREETMAP;/' src/com/android/dialer/lookup/LookupSettings.java; #Change FLP to OpenStreetMap
sed -i 's/CMSettings.System.ENABLE_FORWARD_LOOKUP, 1)/CMSettings.System.ENABLE_FORWARD_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable FLP
sed -i 's/CMSettings.System.ENABLE_PEOPLE_LOOKUP, 1)/CMSettings.System.ENABLE_PEOPLE_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable PLP
sed -i 's/CMSettings.System.ENABLE_REVERSE_LOOKUP, 1)/CMSettings.System.ENABLE_REVERSE_LOOKUP, 0)/' src/com/android/dialer/lookup/LookupSettings.java; #Disable RLP

cd $base"packages/apps/FDroid"
sed -i 's|DEFAULT_ROOTED = true;|DEFAULT_ROOTED = false;|' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide root apps
sed -i 's|DEFAULT_HIDE_ANTI_FEATURE_APPS = false;|DEFAULT_HIDE_ANTI_FEATURE_APPS = true;|' app/src/main/java/org/fdroid/fdroid/Preferences.java; #Hide anti-feature apps

cd $base"packages/apps/Jelly"
#Because someone is going to eventually ask... the reason we're disabling ads on DuckDuckgGo is because their ads are shit and are almost always just links to what you search for on some shit tier ad infested metasearch engine. Like if DuckDuckGo partnered with Amazon or something and showed sponsored Amazon links that would be a million times better, because they are actually ads.
#sed -i 's|duckduckgo.com/?q=|duckduckgo.com/?k1=-1&kaq=-1&kap=-1&kao=-1&kak=-1&kax=-1&q=|' app/src/main/res/values/search_engines.xml; #Disable ads and popups
#sed -i 's|default_search_engine">https://google.com/search?ie=UTF-8&amp;source=android-browser&amp;q={searchTerms}|default_search_engine">https://duckduckgo.com/?k1=-1&kaq=-1&kap=-1&kao=-1&kak=-1&kax=-1&q={searchTerms}|' app/src/main/res/values/strings.xml; #Change default search engine TODO: Fix me
#sed -i 's|default_home_page">https://google.com|default_home_page">https://duckduckgo.com/?k1=-1&kaq=-1&kap=-1&kao=-1&kak=-1&kax=-1|' app/src/main/res/values/strings.xml; #Change homepage from Google to DuckDuckGo
sed -i 's|default_suggestion_provider">GOOGLE|default_suggestion_provider">NONE|' app/src/main/res/values/strings.xml; #Disable search suggestions
sed -i 's|KEY_LOCATION, true|KEY_LOCATION, false|' app/src/main/java/org/lineageos/jelly/utils/PrefsUtils.java; #Disable location
sed -i 's|KEY_DO_NOT_TRACK, false|KEY_DO_NOT_TRACK, true|' app/src/main/java/org/lineageos/jelly/utils/PrefsUtils.java; #Enable do not track
sed -i 's|KEY_SAVE_FORM_DATA, true|KEY_SAVE_FORM_DATA, false|' app/src/main/java/org/lineageos/jelly/utils/PrefsUtils.java; #Disable form data saving
sed -i 's|KEY_REMOVE_IDENTIFYING_HEADERS, false|KEY_REMOVE_IDENTIFYING_HEADERS, true|' app/src/main/java/org/lineageos/jelly/utils/PrefsUtils.java; #Remove certain headers

cd $base"packages/apps/Nfc"
sed -i 's/static final boolean NFC_ON_DEFAULT = true;/static final boolean NFC_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NFC
sed -i 's/static final boolean NDEF_PUSH_ON_DEFAULT = true;/static final boolean NDEF_PUSH_ON_DEFAULT = false;/' src/com/android/nfc/NfcService.java; #Disable NDEF Push

cd $base"packages/apps/Settings"
sed -i 's/Settings.Secure.WEB_ACTION_ENABLED, 1/Settings.Secure.WEB_ACTION_ENABLED, 0/' src/com/android/settings/applications/ManageDomainUrls.java; #Disable "Instant Apps"

cd $base"packages/apps/Trebuchet"
sed -i 's|homescreen_search_default">true|homescreen_search_default">false|' res/values/preferences_defaults.xml; #Disable search
sed -i 's|drawer_compact_default">false|drawer_compact_default">true|' res/values/preferences_defaults.xml; #Enable compact view
sed -i 's|use_scroller_default">true|use_scroller_default">false|' res/values/preferences_defaults.xml; #Hide scroller
sed -i 's|drawer_search_default">true|drawer_search_default">false|' res/values/preferences_defaults.xml; #Disable search

cd $base
echo "Default settings changed!"
