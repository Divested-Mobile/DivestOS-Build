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

#Updates select user facing strings
#Last verified: 2018-04-27

echo "Rebranding...";

enter "bootable/recovery";
git revert bc57208dfcd0958d03a00bbcf5345be6ceac9988 6ac3bb48f9d10e604d4b2d6c4152be9d35d17ea0;
patch -p1 < "$patches/android_bootable_recovery/0001-Remove_Logo.patch"; #Remove logo rendering code
rm res*/images/logo_image.png; #Remove logo images
sed -i 's|Android Recovery|'"$REBRAND_NAME"' Recovery|' ./*_ui.cpp;
sed -i 's|LineageOS|'"$REBRAND_NAME"'|' ui.cpp;

enter "build/make";
sed -i 's|echo "ro.build.user=$USER"|echo "ro.build.user=emy"|' tools/buildinfo.sh; #Override build user
sed -i 's|echo "ro.build.host=`hostname`"|echo "ro.build.host=dosbm"|' tools/buildinfo.sh; #Override build host

enter "frameworks/base";
generateBootAnimationMask "$REBRAND_NAME" "$REBRAND_BOOTANIMATION_FONT" core/res/assets/images/android-logo-mask.png;

enter "lineage-sdk";
sed -i '/.*lineage_version/s/LineageOS/'"$REBRAND_NAME"'/' lineage/res/res/values*/strings.xml;
sed -i '/.*lineage_updates/s/LineageOS/'"$REBRAND_NAME"'/' lineage/res/res/values*/strings.xml;
sed -i '/.*lineageos_system_label/s/LineageOS/'"$REBRAND_NAME"'/' lineage/res/res/values*/strings.xml;

enter "packages/apps/LineageParts";
sed -i '/.*trust_feature_security_patches_explain/s/LineageOS/'"$REBRAND_NAME"'/' res/values*/strings.xml;

enter "packages/apps/Settings";
sed -i '/.*lineagelicense_title/s/LineageOS/'"$REBRAND_NAME"'/' res/values*/cm_strings.xml;

enter "packages/apps/SetupWizard";
sed -i 's|http://lineageos.org/legal|https://divestos.xyz/index.php?page=privacy_policy|' src/org/lineageos/setupwizard/LineageSettingsActivity.java;
sed -i '/.*setup_services/s/LineageOS/'"$REBRAND_NAME"'/' res/values*/strings.xml;
sed -i '/.*services_explanation/s/LineageOS/'"$REBRAND_NAME"'/' res/values*/strings.xml;
cp "$patches/android_packages_apps_SetupWizard/logo.xml" "res/drawable/logo.xml"; #Replace Lineage logo with ours

enter "packages/apps/Updater";
sed -i 's|>LineageOS|>'"$REBRAND_NAME"'|' res/values*/strings.xml;

enter "vendor/lineage";
sed -i 's|https://lineageos.org/legal|'"$REBRAND_LEGAL"'|' build/core/main_version.mk
sed -i '/.*ZIPPATH=/s/lineage/'"$REBRAND_ZIP_PREFIX"'/' build/envsetup.sh;
sed -i '/LINEAGE_TARGET_PACKAGE/s/lineage/'"$REBRAND_ZIP_PREFIX"'/' build/tasks/bacon.mk;
rm -rf bootanimation;

cd "$base";
echo "Rebranding complete!";
