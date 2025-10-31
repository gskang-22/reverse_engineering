#!/bin/sh

while(true)
do
    ALL=$(conntrack -L |grep udp| awk -F" " '{print $3}')
    let max=1
    for n in $ALL; do
        let number=$((n))
        if [ $max -lt $number ]; then
            max=$number
        fi
    done

    limit=$(cat /proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream)
    if [ $max -gt $limit ]; then
        echo "About to flush conntrack"
        conntrack -F 
        uptime >> /logs/conntrack
        echo $max >> /logs/conntrack
    fi
    sleep 3600
done
