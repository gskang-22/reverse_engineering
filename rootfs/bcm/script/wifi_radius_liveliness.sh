#!/bin/sh
#usage ./filename <type [0 - 2.4GHz] | [1 - 5GHz]> <interface> <index> <primary ip> <secondary ip>

echo "" > /tmp/ping_output_"$2"

if [ ! -z "$1" -a "$result" != " " ]; then
if [ ! -z "$2" -a "$result" != " " ]; then
if [ ! -z "$3" -a "$result" != " " ]; then

    echo "Type - $1 Interface - $2 and index - $3" >> /tmp/ping_output_"$2"
    if [ ! -z "$4" -a "$result" != " " ]; then
        echo "Primary IP - $4" >> /tmp/ping_output_"$2"
        result=`ping $4 -c 3 | grep " 0% packet loss"`
        echo $result >> /tmp/ping_output_"$2"
        
        if [ ! -z "$result" -a "$result" != " " ]; then
            echo "Primary is UP" >> /tmp/ping_output_"$2"
            #Primary
            if [ "$1" == 0 ]; then
                wl -i $2 bss -C $3 up
            else
                qcsapi_sockraw eth4.0 00:26:86:00:00:00 set_option $2 SSID_broadcast 1
            fi
            exit
        fi
    fi
    
    if [ ! -z "$5" -a "$result" != " " ]; then
        echo "Secondary IP - $5" >> /tmp/ping_output_"$2"
        result=`ping $5 -c 3 | grep " 0% packet loss"`
        echo $result >> /tmp/ping_output_"$2"
        
        if [ ! -z "$result" -a "$result" != " " ]; then
            echo "Secondary is UP" >> /tmp/ping_output_"$2"
            #Secondary
            if [ "$1" == 0 ]; then
                wl -i $2 bss -C $3 up
            else
                qcsapi_sockraw eth4.0 00:26:86:00:00:00 set_option $2 SSID_broadcast 1
            fi
            exit
        fi
    fi
    
    #Both down
    echo "Both Primary and sencondary was down" >> /tmp/ping_output_"$2"
    if [ "$1" == 0 ]; then
        wl -i $2 bss -C $3 down
    else
        qcsapi_sockraw eth4.0 00:26:86:00:00:00 set_option $2 SSID_broadcast 0
    fi
fi
fi
fi

