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

#Updates select user facing strings

echo "Rebranding..."

enter "bootable/recovery"
sed -i 's|Android Recovery|DivestOS Recovery|' *_ui.cpp;

enter "build/make"
sed -i 's|echo "ro.build.user=$USER"|echo "ro.build.user=emy"|' tools/buildinfo.sh; #Override build user
sed -i 's|echo "ro.build.host=`hostname`"|echo "ro.build.host=dosbm"|' tools/buildinfo.sh; #Override build host

enter "packages/apps/Settings"
sed -i '/.*lineagelicense_title/s/LineageOS/DivestOS/' res/values*/cm_strings.xml
#sed -i '/.*cmupdate_settings_title/s/LineageOS/DivestOS/' res/values*/cm_strings.xml
#sed -i '/.*mod_version/s/LineageOS/DivestOS/' res/values*/cm_strings.xml

enter "packages/apps/SetupWizard"
sed -i 's|http://lineageos.org/legal|https://divestos.xyz/pages/legal/pp.html|' src/org/lineageos/setupwizard/LineageSettingsActivity.java;
sed -i '/.*setup_services/s/LineageOS/DivestOS/' res/values*/strings.xml
sed -i '/.*services_explanation/s/LineageOS/DivestOS/' res/values*/strings.xml
cp $patches"android_packages_apps_SetupWizard/logo.xml" "res/drawable/logo.xml"; #Replace Lineage logo with ours

enter "packages/apps/Updater"
sed -i 's|>LineageOS|>DivestOS|' res/values*/strings.xml

enter "vendor/lineage"
sed -i 's|https://lineageos.org/legal|https://divestos.xyz/pages/about.html|' config/common.mk;
sed -i '/.*ZIPPATH=/s/lineage/coverage/' build/envsetup.sh;
sed -i '/LINEAGE_TARGET_PACKAGE/s/lineage/coverage/' build/tasks/bacon.mk
rm -rf bootanimation #TODO: Create a boot animation

cd $base
echo "Rebranding complete!"
