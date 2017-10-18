#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Replaces teal accents with orange ones

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"

echo "Applying theme..."

cd $base"frameworks/base"
sed -i 's/#ffe0f2f1/#ffffd54f/' core/res/res/values/colors_material.xml #50
sed -i 's/#ffb2dfdb/#ffffca28/' core/res/res/values/colors_material.xml #100
sed -i 's/#ff80cbc4/#ffffa726/' core/res/res/values/colors_material.xml #200
sed -i 's/#ff4db6ac/#ffff9800/' core/res/res/values/colors_material.xml #300
sed -i 's/#ff009688/#ffff5722/' core/res/res/values/colors_material.xml #500
sed -i 's/#ff00796b/#ffe64a19/' core/res/res/values/colors_material.xml #700

cd $base"packages/apps/GmsCore"
sed -i 's/#ff7fcac3/#ffff9800/' microg-ui-tools/src/main/res/values/colors.xml #300
sed -i 's/#ff009688/#ffff5722/' microg-ui-tools/src/main/res/values/colors.xml #500

#cd $base"packages/apps/Settings"
#sed -i 's///' res/values/colors.xml
#TODO: Fix 'Storage'

cd $base"packages/inputmethods/LatinIME"
sed -i 's/#80CBC4/#ffa726/' java/res/values/colors.xml #200
sed -i 's/#4DB6AC/#ff9800/' java/res/values/colors.xml #300

cd $base
echo "Applied theme!"
