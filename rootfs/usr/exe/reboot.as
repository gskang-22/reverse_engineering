#!/bin/sh
# action set during reboot
# it will be called by "/etc/inittab"
# the common action can be defined here
# Note: the commands should use full path
# 2014.11.05, <Fuguo.Xu@alcatel-sbell.com.cn >

/bin/touch /configs/warm_boot_flag

/bin/echo "[`/bin/date -u '+%F %T'`]MSG: system shutdown" >> /logs/.default.log

## Power down optics Tx for some special ont
/sbin/bob pwd 31853211
/sbin/bob txctrl 0

## Set all LED on during soft reboot, special for g240wc
/sbin/ledtool 2 6

# for Quntina CPU reset
if [ "$(/usr/exe/hcfgtool get WIFI.1.SOLUTION)" == "QTN11AC" ]; then
    /sbin/gpio_tool wifireset 1 1
fi

[ -x /usr/exe/whw/bin/aiengine.load ] && /usr/exe/whw/bin/aiengine.load save &
