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

#Attempts to increase performance and battery life

echo "Optimizing..."

enter "frameworks/base"
sed -i 's/ScaleSetting = 1.0f;/ScaleSetting = 0.5f;/' services/core/java/com/android/server/wm/WindowManagerService.java;
sed -i 's|config_useVolumeKeySounds">true|config_useVolumeKeySounds">false|' core/res/res/values/config.xml;
sed -i 's|config_radioScanningTimeout">0|config_radioScanningTimeout">300000|' core/res/res/values/config.xml;
sed -i 's|config_wifi_fast_bss_transition_enabled">false|config_wifi_fast_bss_transition_enabled">true|' core/res/res/values/config.xml;
sed -i 's|config_wifi_enable_wifi_firmware_debugging">true|config_wifi_enable_wifi_firmware_debugging">false|' core/res/res/values/config.xml;
sed -i 's|config_wifi_supplicant_scan_interval">15000|config_wifi_supplicant_scan_interval">120000|' core/res/res/values/config.xml;
sed -i 's|config_autoBrightnessLightSensorRate">250|config_autoBrightnessLightSensorRate">1000|' core/res/res/values/config.xml;
#sed -i 's|config_buttonLightOnKeypressOnly">false|config_buttonLightOnKeypressOnly">true|' core/res/res/values/config.xml;
sed -i 's|config_recents_use_hardware_layers">false|config_recents_use_hardware_layers">true|' packages/SystemUI/res/values/config.xml;
sed -i 's|config_recents_fake_shadows">false|config_recents_fake_shadows">true|' packages/SystemUI/res/values/config.xml;
sed -i 's|config_notifications_round_rect_clipping">true|config_notifications_round_rect_clipping">false|' packages/SystemUI/res/values/config.xml;
sed -i 's|config_showTemperatureWarning">0|config_showTemperatureWarning">1|' packages/SystemUI/res/values/config.xml; #XXX: Doesn't seem to work?
#sed -i 's|||'

cd $base
echo "Optimizing complete!"
