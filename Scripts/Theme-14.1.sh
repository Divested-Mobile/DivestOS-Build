#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Replaces teal accents with dark orange ones

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"

echo "Applying theme..."

cd $base"frameworks/base"
sed -i 's/#ffe0f2f1/#fffbe9e7/' core/res/res/values/colors_material.xml #50
sed -i 's/#ffb2dfdb/#ffffccbc/' core/res/res/values/colors_material.xml #100
sed -i 's/#ff80cbc4/#ffffab91/' core/res/res/values/colors_material.xml #200
sed -i 's/#ff4db6ac/#ffff8a65/' core/res/res/values/colors_material.xml #300
sed -i 's/#ff009688/#ffff5722/' core/res/res/values/colors_material.xml #500
sed -i 's/#ff00796b/#ffe64a19/' core/res/res/values/colors_material.xml #700

cd $base"packages/apps/GmsCore"
sed -i 's/#ff7fcac3/#ffff8a65/' microg-ui-tools/src/main/res/values/colors.xml #300
sed -i 's/#ff009688/#ffff5722/' microg-ui-tools/src/main/res/values/colors.xml #500

#cd $base"packages/apps/Settings"
#sed -i 's///' res/values/colors.xml
#TODO: Fix 'Storage'

cd $base"packages/inputmethods/LatinIME"
sed -i 's/#80CBC4/#ffab91/' java/res/values/colors.xml #200
sed -i 's/#4DB6AC/#ff8a65/' java/res/values/colors.xml #300

cd $base
echo "Applied theme!"
