#!/bin/sh

echo ---------- "`date`" -------------
case "$1" in
    0) echo "LED is disabled - instance id = ${2}"
        #check the repeat param
        #cfgcli -s InternetGatewayDevice.X_ALU-COM_LED.Node.'$2'.Enable 0
        #echo "Reoccurance is 0, so disabled the LED node"
        dcmgr ledoff
        ;;
    1) echo "LED is enabled"
        dcmgr ledon
        ;;
    2) 
       for pid in $(ps w | grep "/configs/led/timer" | grep -v grep | awk '{print $1}');do
            if [ x = "x$pid" ]
            then
                echo "pid not found";
             else 
                echo "pid - $pid"
                if [ "$pid" -ge 1 ]
                then
                    kill $pid
                fi
            fi
         done
        ;;
esac
echo ---------------------------------
