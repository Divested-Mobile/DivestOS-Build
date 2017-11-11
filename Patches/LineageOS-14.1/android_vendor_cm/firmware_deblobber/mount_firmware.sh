#!/sbin/sh

if mount /firmware; then
    exit 0
fi

# Try to get the block from /etc/recovery.fstab
block=`cat /etc/recovery.fstab | cut -d '#' -f 1 | grep /firmware | grep -o '/dev/[^ ]*' | head -1`
if [ -n "$block" ] && mount $block /firmware; then
    exit 0
fi

exit 1
