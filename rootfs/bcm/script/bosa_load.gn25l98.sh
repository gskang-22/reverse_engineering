#!/bin/sh
device="bosa"
group="wheel"
mode="664"

echo "***load GN25L98 bosa***"

#insmod driver module.
insmod /bcm/bin/bosa_semetech.ko

# remove stale nodes
rm -f /dev/$device
major=`cat /proc/devices | awk '$2 == "bosa" {print $1}'`

minor=0
mknod /dev/$device c $major $minor

#bosa init
mdev -s
bob.gn25l98 init


