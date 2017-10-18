#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Replaces teal accents with orange ones

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"

echo "Applying theme..."

cd $base"frameworks/base"
sed -i 's/#ffe0f2f1/#ffffd54f/' core/res/res/values/colors_material.xml
sed -i 's/#ffb2dfdb/#ffffca28/' core/res/res/values/colors_material.xml
sed -i 's/#ff80cbc4/#ffffa726/' core/res/res/values/colors_material.xml
sed -i 's/#ff4db6ac/#ffff9800/' core/res/res/values/colors_material.xml
sed -i 's/#ff009688/#ffff5722/' core/res/res/values/colors_material.xml
sed -i 's/#ff00796b/#ffe64a19/' core/res/res/values/colors_material.xml

cd $base"packages/apps/GmsCore/"
sed -i 's/#ff009688/#ffff5722/' microg-ui-tools/src/main/res/values/colors.xml
sed -i 's/#ff7fcac3/#ff4db6ac/' microg-ui-tools/src/main/res/values/colors.xml

cd $base
echo "Applied theme!"
