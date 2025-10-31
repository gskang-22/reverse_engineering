#!/bin/sh
#Script to restart the vnstatd process

result=`cat /etc/buildinfo | grep ONT_TYPE | cut -d = -f2`
if [ "$result" != "g240wa" -a "$result" != "g240wb" -a "$result" != "g240wz" -a "$result" != "f240wa" -a "$result" != "ha030wb" -a "$result" != "ha020wb" -a "$result" != "g240we" ]; then
    pkill -9 vnstatd
    /sbin/vnstatd -d
fi


