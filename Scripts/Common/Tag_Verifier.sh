#!/bin/bash
#DivestOS: A mobile operating system divested from the norm.
#Copyright (c) 2022-2023 Divested Computing Group
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
umask 0022;
#set -uo pipefail;
source "$DOS_SCRIPTS_COMMON/Shell.sh";

gpgVerifyGitTag() {
	if [ -r "$DOS_TMP_GNUPG/pubring.kbx" ]; then
		tagMatch=$(git -C "$1" describe --exact-match HEAD);
		if [ ! -z "$tagMatch" ]; then
			if git -C "$1" verify-tag "$tagMatch" &>/dev/null; then
				echo -e "\e[0;32mGPG Verified Git Tag Successfully: $1\e[0m";
			else
				echo -e "\e[0;31mWARNING: GPG Verification of Git Tag Failed: $1\e[0m";
				#sleep 60;
			fi;
		else
			echo -e "\e[0;33mWARNING: No tag match for $1 \e[0m";
		fi;
		#git -C $1 log --show-signature -1;
	else
		echo -e "\e[0;33mWARNING: keyring is unavailable, GPG verification of $1 will not be performed!\e[0m";
	fi;
}
export -f gpgVerifyGitTag;

verifyTagIfPlatform() {
	if [[ "$1" == "platform/"* ]]; then
		gpgVerifyGitTag "$DOS_BUILD_BASE/$2";
	fi;
}
export -f verifyTagIfPlatform;
