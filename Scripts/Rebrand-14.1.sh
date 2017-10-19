#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Updates select user facing strings

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"

echo "Rebranding..."

cd $base"packages/apps/Settings"
sed -i '/.*cmlicense_title/s/LineageOS/DivestOS/' res/values*/cm_strings.xml
sed -i '/.*cmupdate_settings_title/s/LineageOS/DivestOS/' res/values*/cm_strings.xml
sed -i '/.*mod_version/s/LineageOS/DivestOS/' res/values*/cm_strings.xml

cd $base"packages/apps/SetupWizard"
sed -i 's|http://lineageos.org/legal|https://divestos.xyz/pages/legal/pp.html|' src/com/cyanogenmod/setupwizard/LineageSettingsActivity.java;
sed -i '/.*setup_services/s/LineageOS/DivestOS/' res/values*/strings.xml
sed -i '/.*services_explanation/s/LineageOS/DivestOS/' res/values*/strings.xml

cd $base"packages/apps/Updater"
sed -i 's|>LineageOS|>DivestOS|' res/values*/strings.xml

cd $base"vendor/cm"
sed -i 's|http://lineageos.org/legal|https://divestos.xyz/pages/about.html|' config/common.mk;
#sed -i '/.*ZIPFILE=/s/lineage/divestos/' build/envsetup.sh
rm -rf bootanimation #TODO: Create a boot animation

cd $base
echo "Rebranding complete!"
