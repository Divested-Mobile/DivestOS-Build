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
unalias cp &>/dev/null || true;
unalias mv &>/dev/null || true;
unalias rm &>/dev/null || true;
unalias ln &>/dev/null || true;
unalias mount &>/dev/null || true;
unalias unmount &>/dev/null || true;
unalias chown &>/dev/null || true;
unalias chmod &>/dev/null || true;
unalias chgrp &>/dev/null || true;
unalias rmdir &>/dev/null || true;
unalias mkdir &>/dev/null || true;
unalias patch &>/dev/null || true;
alias patch='patch --no-backup-if-mismatch';
alias cp='cp --reflink=auto'
