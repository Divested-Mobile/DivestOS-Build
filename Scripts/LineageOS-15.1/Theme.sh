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

#Replaces teal accents with orange/yellow ones

echo "Applying theme..."

export themeOverride50="FFCA28" #Amber 400
export themeOverride100="FFC107" #Amber 500
export themeOverride200="FFA726" #Orange 400
export themeOverride300="FF9800" #Orange 500
export themeOverride500="FF5722" #Deep Orange 500
export themeOverride700="E64A19" #Deep Orange 700

#export themeOverride50="26C6DA" #Cyan 400
#export themeOverride100="00BCD4" #Cyan 500
#export themeOverride200="29B6F6" #Light Blue 400
#export themeOverride300="03A9F4" #Light Blue 500
#export themeOverride500="2196F3" #Blue 500
#export themeOverride700="1976D2" #Blue 700

enter "frameworks/base"
sed -i "s/#ffe0f2f1/#ff$themeOverride50/" core/res/res/values/colors_material.xml
sed -i "s/#ffb2dfdb/#ff$themeOverride100/" core/res/res/values/colors_material.xml
sed -i "s/#ff80cbc4/#ff$themeOverride200/" core/res/res/values/colors_material.xml
sed -i "s/#ff4db6ac/#ff$themeOverride300/" core/res/res/values/colors_material.xml
sed -i "s/#ff009688/#ff$themeOverride500/" core/res/res/values/colors_material.xml
sed -i "s/#ff00796b/#ff$themeOverride700/" core/res/res/values/colors_material.xml
sed -i "s/#fff4511e/#ffe53935/" core/res/res/values/colors.xml

enter "packages/apps/GmsCore"
sed -i "s/#ff7fcac3/#ff$themeOverride300/" microg-ui-tools/src/main/res/values/colors.xml
sed -i "s/#ff009688/#ff$themeOverride500/" microg-ui-tools/src/main/res/values/colors.xml

enter "packages/apps/LineageParts"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/colors.xml

enter "packages/apps/Settings"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/styles.xml
#TODO: Fix: Storage, Profiles

enter "packages/apps/Trebuchet"
sed -i "s/009688/$themeOverride500/" res/values/*colors.xml
sed -i "s/009688/$themeOverride500/" WallpaperPicker/res/values/colors.xml
mogrify -format png -fill "#$themeOverride500" -opaque "#009688" -fuzz 10% res/drawable*/cling_bg.9.png
#TODO: Fix: Open app icon

enter "packages/apps/Updater"
sed -i "s/#ff009688/#ff$themeOverride500/" res/values/colors.xml

enter "packages/inputmethods/LatinIME"
sed -i "s/#80CBC4/#$themeOverride200/" java/res/values/colors.xml
sed -i "s/#4DB6AC/#$themeOverride300/" java/res/values/colors.xml
mogrify -format png -fill "#$themeOverride100" -opaque "#b2dfdb" -fuzz 10% java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride200" -opaque "#80cbc4" -fuzz 10% java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride300" -opaque "#4db6ac" -fuzz 10% java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride300" -opaque "#7fcac3" -fuzz 10% java/res/drawable*/*lxx*.png
mogrify -format png -fill "#$themeOverride400" -opaque "#26a69a" -fuzz 10% java/res/drawable*/*lxx*.png

cd $base
echo "Applied theme!"
