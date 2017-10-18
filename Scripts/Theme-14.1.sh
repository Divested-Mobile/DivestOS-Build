#!/bin/bash
#Copyright (c) 2015-2017 Spot Communications, Inc.

#Replaces teal accents with orange/yellow ones

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/"

echo "Applying theme..."

export themeOverride50="FFCA28"
export themeOverride100="FFC107"
export themeOverride200="FFA726"
export themeOverride300="FF9800"
export themeOverride500="FF5722"
export themeOverride700="E64A19"

cd $base"frameworks/base"
sed -i "s/#ffe0f2f1/#ff$themeOverride50/" core/res/res/values/colors_material.xml
sed -i "s/#ffb2dfdb/#ff$themeOverride100/" core/res/res/values/colors_material.xml
sed -i "s/#ff80cbc4/#ff$themeOverride200/" core/res/res/values/colors_material.xml
sed -i "s/#ff4db6ac/#ff$themeOverride300/" core/res/res/values/colors_material.xml
sed -i "s/#ff009688/#ff$themeOverride500/" core/res/res/values/colors_material.xml
sed -i "s/#ff00796b/#ff$themeOverride700/" core/res/res/values/colors_material.xml

cd $base"packages/apps/CMParts"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/colors.xml

cd $base"packages/apps/GmsCore"
sed -i "s/#ff7fcac3/#ff$themeOverride300/" microg-ui-tools/src/main/res/values/colors.xml
sed -i "s/#ff009688/#ff$themeOverride500/" microg-ui-tools/src/main/res/values/colors.xml

#cd $base"packages/apps/Settings"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/styles.xml

cd $base"packages/apps/Trebuchet"
sed -i "s/009688/$themeOverride500/" res/values/*colors.xml
sed -i "s/009688/$themeOverride500/" WallpaperPicker/res/values/*colors.xml
mogrify -format png -fill "#$themeOverride500" -opaque "#009688" res/drawable*/cling_bg.9.png

cd $base"packages/apps/Updater"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/colors.xml

cd $base"packages/inputmethods/LatinIME"
sed -i "s/#80CBC4/#$themeOverride200/" java/res/values/colors.xml
sed -i "s/#4DB6AC/#$themeOverride300/" java/res/values/colors.xml
mogrify -format png -fill "#$themeOverride100" -opaque "#b2dfdb" java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride200" -opaque "#80cbc4" java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride300" -opaque "#4db6ac" java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride300" -opaque "#7fcac3" java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride400" -opaque "#26a69a" java/res/drawable*/*lxx*.png

cd $base
echo "Applied theme!"
