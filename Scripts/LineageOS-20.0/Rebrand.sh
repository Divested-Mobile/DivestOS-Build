#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2017-2022 Divested Computing Group
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

#Updates select user facing strings
#Last verified: 2022-10-15

echo "Rebranding...";

if enter "bootable/recovery"; then
git revert --no-edit 5319be860bc79b93ee885dd82abb5acaa976a4fd; #use standard animation
awk -i inplace '!/DrawSurface\(logo.get\(\)/' recovery_ui/screen_ui.cpp; #Hide logo
mogrify -format png -fill "#FF5722" -opaque "#167C80" -fuzz 10% res-*/images/*sel.png; #Recolor icons
mogrify -format png -fill "#FF5722" -opaque "#7c4dff" -fuzz 10% res-*/images/ic_back_sel.png;
sed -i 's|0x7c, 0x4d, 0xff|0xff, 0x57, 0x22|' recovery_ui/*ui.cpp; #Recolor accents (recovery primary)
sed -i 's|0xf8, 0x90, 0xff|0xff, 0x98, 0x00|' recovery_ui/*ui.cpp; #Recolor accents (recovery secondary)
sed -i 's|0xe6, 0x51, 0x00|0x4c, 0xaf, 0x50|' recovery_ui/*ui.cpp; #Recolor accents (fastboot primary)
sed -i 's|0xfd, 0xd8, 0x35|0x8b, 0xc3, 0x4a|' recovery_ui/*ui.cpp; #Recolor accents (fastboot secondary)
sed -i 's|0xfd, 0xd8,0x35|0x8b, 0xc3, 0x4a|' recovery_ui/*ui.cpp; #Recolor accents (fastboot secondary typo)
sed -i 's|0x16, 0x7c, 0x80|0x03, 0xa9, 0xf4|' recovery_ui/*ui.cpp; #Recolor text
sed -i 's|Android Recovery|'"$DOS_BRANDING_NAME"' Recovery|' recovery_ui/*ui.cpp; #not used (yet)
sed -i 's|LineageOS|'"$DOS_BRANDING_NAME"'|' recovery_ui/*ui.cpp; #not used (yet)
sed -i 's|"Version "|"'$DOS_BRANDING_NAME' "|' recovery.cpp
fi;

if enter "build/make"; then
sed -i 's|echo "ro.build.user=$BUILD_USERNAME"|echo "ro.build.user=emy"|' tools/buildinfo.sh; #Override build user
sed -i 's|echo "ro.build.host=$BUILD_HOSTNAME"|echo "ro.build.host=dosbm"|' tools/buildinfo.sh; #Override build host
fi;

if enter "frameworks/base"; then
generateBootAnimationMask "$DOS_BRANDING_NAME" "$DOS_BRANDING_BOOTANIMATION_FONT" core/res/assets/images/android-logo-mask.png;
generateBootAnimationShine "$DOS_BRANDING_BOOTANIMATION_COLOR" "$DOS_BRANDING_BOOTANIMATION_STYLE" core/res/assets/images/android-logo-shine.png;
fi;

if enter "lineage-sdk"; then
sed -i '/.*lineage_version/s/LineageOS/'"$DOS_BRANDING_NAME"'/' lineage/res/res/values*/strings.xml;
sed -i '/.*lineage_updates/s/LineageOS/'"$DOS_BRANDING_NAME"'/' lineage/res/res/values*/strings.xml;
sed -i '/.*lineageos_system_label/s/LineageOS/'"$DOS_BRANDING_NAME"'/' lineage/res/res/values*/strings.xml;
fi;

if enter "packages/apps/LineageParts"; then
sed -i '/.*egg_title/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
sed -i '/.*lineageparts_title/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
sed -i '/.*privacy_settings_category/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
sed -i '/.*trust_feature_security_patches_explain/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
fi;

if enter "packages/apps/Settings"; then
sed -i '/.*lineagelicense_title/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/cm_strings.xml;
fi;

if enter "packages/apps/SetupWizard"; then
sed -i 's|https://lineageos.org/legal|'"$DOS_BRANDING_LINK_PRIVACY"'|' src/org/lineageos/setupwizard/LineageSettingsActivity.java;
sed -i 's|https://lineageos.org/legal|'"$DOS_BRANDING_LINK_PRIVACY"'|' res/values*/strings.xml;
sed -i '/.*intro_restore/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
sed -i '/.*os_name/s/LineageOS/'"$DOS_BRANDING_NAME"'/' res/values*/strings.xml;
sed -i '/.*services/s/LineageOS/'"$DOS_BRANDING_NAME"'/g' res/values*/strings.xml;
sed -i '/.*setup_services/s/LineageOS/'"$DOS_BRANDING_NAME"'/g' res/values*/strings.xml;
sed -i '/.*update_recovery/s/Lineage/'"$DOS_BRANDING_NAME"'/g' res/values*/strings.xml;
fi;

if enter "packages/apps/Updater"; then
sed -i 's|0OTA_SERVER_CLEARNET0|'"$DOS_BRANDING_SERVER_OTA"'|' app/src/main/java/org/lineageos/updater/misc/Utils.java;
sed -i 's|0OTA_SERVER_ONION0|'"$DOS_BRANDING_SERVER_OTA_ONION"'|' app/src/main/java/org/lineageos/updater/misc/Utils.java;
sed -i 's|>LineageOS|>'"$DOS_BRANDING_NAME"'|' app/src/main/res/values*/strings.xml;
sed -i '/.*toast_forced_update_recovery/s/Lineage/'"$DOS_BRANDING_NAME"'/g' app/src/main/res/values*/strings.xml;
sed -i '/.*info_dialog_message/s/Lineage/'"$DOS_BRANDING_NAME"'/g' app/src/main/res/values*/strings.xml;
sed -i 's|https://download.lineageos.org/<xliff:g id="device_name">%1$s</xliff:g>/changes|'"$DOS_BRANDING_LINK_NEWS"'|g' app/src/main/res/values*/strings.xml;
fi;

if enter "system/core"; then
sed -i 's/LineageOS/'"$DOS_BRANDING_NAME"'/' debuggerd/libdebuggerd/tombstone.cpp; #not used (yet)
fi;

if enter "vendor/lineage"; then
sed -i 's|https://lineageos.org/legal|'"$DOS_BRANDING_LINK_ABOUT"'|' build/core/main_version.mk;
sed -i '/.*ZIPPATH=/s/lineage/'"$DOS_BRANDING_ZIP_PREFIX"'/' build/envsetup.sh;
sed -i '/LINEAGE_TARGET_PACKAGE/s/lineage/'"$DOS_BRANDING_ZIP_PREFIX"'/' build/tasks/bacon.mk;
sed -i '/.*config_mms_user_agent/s/LineageOS/'"$DOS_BRANDING_NAME"'/g' overlay/common/frameworks/base/core/res/res/values*/config.xml; #not used (yet)
rm -rf bootanimation;
fi;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Rebranding complete\e[0m";
