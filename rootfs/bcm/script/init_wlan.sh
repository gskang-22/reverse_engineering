#!/bin/sh

# if caldata not found on /configs/bcm, use default
test -d /configs/bcm && echo "/configs/bcm dir exists" || mkdir -p /configs/bcm
test -s /configs/bcm/bcm43217_map.bin && echo "bcm43217_map.bin exists" || cp -f /bcm/bin/bcm43217_map.bin /configs/bcm/
test -s /configs/bcm/bcm4352_map.bin && echo "bcm4352_map.bin exists" || cp -f /bcm/bin/bcm4352_map.bin /configs/bcm/
test -s /configs/bcm/bcm43217_nvramvars.bin && echo "bcm43217_nvramvars.bin exists" || cp -f /bcm/bin/bcm43217_nvramvars.bin /configs/bcm/
test -s /configs/bcm/bcm4352_nvramvars.bin && echo "bcm4352_nvramvars.bin exists" || cp -f /bcm/bin/bcm4352_nvramvars.bin /configs/bcm/
test -s /configs/bcm/bcmcmn_nvramvars.bin && echo "bcmcmn_nvramvars.bin exists" || cp -f /bcm/bin/bcmcmn_nvramvars.bin /configs/bcm/
test -e /bcm/bin/bcmmcast.ko && insmod /bcm/bin/bcmmcast.ko || echo "/bcm/bin/bcmmcast.ko not exist"

# WLAN accelerator module
test -e /bcm/bin/wfd.ko && insmod /bcm/bin/wfd.ko || echo "/bcm/bin/wfd.ko not exist"
test -e /bcm/bin/wlemf.ko && insmod /bcm/bin/wlemf.ko || echo "/bcm/bin/wlemf.ko not exist"

# WLAN module

test -s /bcm/bin/wl.ko && insmod /bcm/bin/wl.ko || echo "/bcm/bin/wl.ko not exist"
chrt -r -p 5 $(pidof -s wl0-kthrd)
chrt -r -p 5 $(pidof -s wl1-kthrd)
chrt -r -p 5 $(pidof -s wfd0-thrd)
chrt -r -p 5 $(pidof -s wfd1-thrd)
#ifconfig wl0 up
#ifconfig wl1 up
wl -i wl0 rx_amsdu_in_ampdu 1
wl -i wl1 ampdu_rx_density 7

