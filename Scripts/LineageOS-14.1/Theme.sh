#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2017-2021 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.
umask 0022;
set -euo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

#Replaces teal accents with orange/yellow ones
#Last verified: 2021-10-16

echo "Applying theme...";

if enter "frameworks/base"; then
sed -i "s/#ffe0f2f1/#ff$DOS_THEME_50/" core/res/res/values/colors_material.xml;
sed -i "s/#ffb2dfdb/#ff$DOS_THEME_100/" core/res/res/values/colors_material.xml;
sed -i "s/#ff80cbc4/#ff$DOS_THEME_200/" core/res/res/values/colors_material.xml;
sed -i "s/#ff4db6ac/#ff$DOS_THEME_300/" core/res/res/values/colors_material.xml;
sed -i "s/#ff009688/#ff$DOS_THEME_500/" core/res/res/values/colors_material.xml;
sed -i "s/#ff00796b/#ff$DOS_THEME_700/" core/res/res/values/colors_material.xml;
sed -i "s/#fff4511e/#ffe53935/" core/res/res/values/colors.xml;
fi;

if enter "packages/apps/CMParts"; then
sed -i "s/#ff009688/#ff$DOS_THEME_500/" res/values/colors.xml;
fi;

if enter "packages/apps/Settings"; then
sed -i "s/#ff009688/#ff$DOS_THEME_500/" res/values/styles.xml;
#TODO: Fix: Storage, Profiles
fi;

if enter "packages/apps/Trebuchet"; then
sed -i "s/009688/$DOS_THEME_500/" res/values/*colors.xml;
sed -i "s/009688/$DOS_THEME_500/" WallpaperPicker/res/values/colors.xml;
mogrify -format png -fill "#$DOS_THEME_500" -opaque "#009688" -fuzz 10% res/drawable*/cling_bg.9.png;
#TODO: Fix: Open app icon
fi;

if enter "packages/apps/Updater"; then
sed -i "s/#ff009688/#ff$DOS_THEME_500/" res/values/colors.xml;
fi;

if enter "packages/inputmethods/LatinIME"; then
sed -i "s/#80CBC4/#$DOS_THEME_200/" java/res/values/colors.xml;
sed -i "s/#4DB6AC/#$DOS_THEME_300/" java/res/values/colors.xml;
mogrify -format png -fill "#$DOS_THEME_100" -opaque "#b2dfdb" -fuzz 10% java/res/drawable*/*lxx*.png;
mogrify -format png -fill "#$DOS_THEME_200" -opaque "#80cbc4" -fuzz 10% java/res/drawable*/*lxx*.png;
mogrify -format png -fill "#$DOS_THEME_300" -opaque "#4db6ac" -fuzz 10% java/res/drawable*/*lxx*.png;
mogrify -format png -fill "#$DOS_THEME_300" -opaque "#7fcac3" -fuzz 10% java/res/drawable*/*lxx*.png;
mogrify -format png -fill "#$DOS_THEME_500" -opaque "#26a69a" -fuzz 10% java/res/drawable*/*lxx*.png;
fi;

cd "$DOS_BUILD_BASE";
echo -e "\e[0;32m[SCRIPT COMPLETE] Applied theme\e[0m";
