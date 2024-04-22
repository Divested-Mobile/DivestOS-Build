#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2020-2023 Divested Computing Group
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

setStrict() {
	if [ -d "$1" ]; then
		find "$1" -type d -print0 | xargs -0 chmod -v 0700;
		find "$1" -type f -print0 | xargs -0 chmod -v 0600;
	fi;
}

setRelaxed() {
	if [ -d "$1" ]; then
		find "$1" -type d -print0 | xargs -0 chmod -v 0755;
		find "$1" -type f -print0 | xargs -0 chmod -v 0644;
	fi;
}

chmod -v 600 LICENSE* pending_commit.txt TODO;
setStrict Logs;
setStrict Manifests;
setStrict Misc;
setStrict Patches/Common;
setRelaxed Patches/Common/android_system_ca-certificates;
setRelaxed Patches/Common/android_timekeep_sepolicy;
setRelaxed Patches/Common/android_vendor_divested;
setStrict Patches/LineageOS-14.1;
setStrict Patches/LineageOS-15.1;
setStrict Patches/LineageOS-16.0;
setStrict Patches/LineageOS-17.1;
setStrict Patches/Linux; #XXX: move this into the repo
chmod -v 700 Patches/Linux/*.sh;
#PrebuiltApps has its own fix_permissions.sh
#Patches/Wallpapers has its own fix_permissions.sh
setStrict Scripts;
setRelaxed Repos/firmware;
setRelaxed Repos/firmware-empty;
setRelaxed Repos/firmware-19.1;
setRelaxed Repos/DivestOS_WebView/prebuilt;
