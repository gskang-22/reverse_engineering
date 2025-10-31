#!/bin/sh
module="bosa_discrete"
device="bosa"
group="wheel"
mode="664"
M_dir=/bcm/bin

if [ ! -d /configs/bosa ]; then
        mkdir -p /configs/bosa
        chmod g+w /configs/bosa
        chgrp wheel /configs/bosa
fi

# invoke insmod with all arguments we got
# and use a pathname, as newer modutils don't look in . by default
/sbin/insmod $M_dir/$module.ko $* || exit 1

# remove stale nodes
rm -f /dev/$device


major=`cat /proc/devices | awk "\\$2==\"$device\" {print \\$1}"`
#minor=`cat /proc/misc | grep ${module} | sed -e 's/^[^0-9]*//' | cut -d " " -f 1`
minor=0
mknod /dev/$device c $major $minor

# give appropriate group/permissions
chgrp $group /dev/${device}
chmod $mode  /dev/${device}

#if /dev/sfp0 exist, remove it. app distinguish bosa between sfp base on this.
rm -f /dev/sfp0
