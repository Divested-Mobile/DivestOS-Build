#!/bin/sh
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2022 Divested Computing Group
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
set -uo pipefail;

mkdir drawable-nodpi drawable-hdpi drawable-xhdpi drawable-xxhdpi drawable-xxxhdpi drawable-sw600dp-nodpi drawable-sw720dp-nodpi;

cp -fv "$1" drawable-nodpi/default_wallpaper.png;
cp -fv "$1" drawable-hdpi/default_wallpaper.png;
cp -fv "$1" drawable-xhdpi/default_wallpaper.png;
cp -fv "$1" drawable-xxhdpi/default_wallpaper.png;
cp -fv "$1" drawable-xxxhdpi/default_wallpaper.png;

mogrify -resize x960 -gravity "$2" -extent 960x960 drawable-nodpi/default_wallpaper.png;
mogrify -resize x1080 -gravity "$2" -extent 1080x1080 drawable-hdpi/default_wallpaper.png;
mogrify -resize x1440 -gravity "$2" -extent 1440x1440 drawable-xhdpi/default_wallpaper.png;
mogrify -resize x1920 -gravity "$2" -extent 1920x1920 drawable-xxhdpi/default_wallpaper.png;
mogrify -resize x2560 -gravity "$2" -extent 2560x2560 drawable-xxxhdpi/default_wallpaper.png;

cp -fv drawable-xxhdpi/default_wallpaper.png drawable-sw600dp-nodpi/;
cp -fv drawable-xxhdpi/default_wallpaper.png drawable-sw720dp-nodpi/;
