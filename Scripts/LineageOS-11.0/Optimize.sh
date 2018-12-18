#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing, Inc.
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

#Attempts to increase performance and battery life
#Last verified: 2018-07-10

echo "Optimizing...";

enter "kernel"
sed -i "s/#define VM_MAX_READAHEAD\t128/#define VM_MAX_READAHEAD\t512/" ./*/*/include/linux/mm.h; #Lee Susman <lsusman@codeaurora.org>: Change the VM_MAX_READAHEAD value from the default 128KB to 512KB. This will allow the readahead window to grow to a maximum size of 512KB, which greatly benefits to sequential read throughput.

cd "$DOS_BUILD_BASE";
echo "Optimizing complete!";
