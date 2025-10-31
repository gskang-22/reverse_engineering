#!/bin/sh
mac_addr=`wl status | grep BSSID | cut -f 1 | awk -F '[  ]'  '{print $2}'`;
if [ "$mac_addr" != "00:00:00:00:00:00" ];then

    wl sta_info "$mac_addr" | grep "AUTHORIZED" >/dev/null 2>&1
    is_wps_4_way_handshake_finish=$?

    if [ $is_wps_4_way_handshake_finish = 0 ];then
    touch /tmp/is_wps_4_way_handshake_finish 
    echo "wps ok, 4 way handshake finish"
    fi
fi

