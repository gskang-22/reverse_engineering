#!/bin/sh
device="bosa"
group="wheel"
mode="664"

echo "***load semetech bosa***"

# compatible with old board. the old is "bosa.cfg"
if [ -f /configs/bosa/bosa.cfg ] && [ ! -f /configs/bosa/cfg.bob ]; then
    cp /configs/bosa/bosa.cfg /configs/bosa/cfg.bob
fi

#insmod driver module.
insmod /bcm/bin/bosa_semetech.ko

# remove stale nodes
rm -f /dev/$device  
major=`cat /proc/devices | awk '$2 == "bosa" {print $1}'`

minor=0
mknod /dev/$device c $major $minor

#bosa init
mdev -s
bob.semetech init

