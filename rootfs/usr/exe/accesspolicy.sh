#!/bin/sh
#Example:
#   accesspolicy.sh policy_id enter
#   accesspolicy.sh policy_id exit

if [ $# -lt 2 ]; then
    echo "no enough parameters"
    echo "  usage:"
    echo "  accesspolicy_1.sh policy_id enter/exit"
    exit 1
fi

enable()
{
    iptables -F ACCESSPOLICY_$1
    policy=$(cfgcli -e AccessPolicy.$1. | grep -E 'SourceMAC|SourceIP' | cut -d '"' -f 10,11)
    hosts=$(cfgcli -e Hosts. | grep -E 'IPAddress|MACAddress' | sed 'N;s/\n/ /g' | cut -d '"' -f 10,20)
    for source in $policy
    do
        result=$(echo $source | grep 'SourceMAC')
        if [ "$result" != "" ]; then
            smac=$(echo $source | cut -d '"' -f 1)
            if [ -n "$smac" ]; then
                iptables -A ACCESSPOLICY_$1 -i br0 -m mac --mac-source $smac -j DROP
                inhosts=$(echo $hosts | grep $smac)
                if [ "$inhosts" != "" ]; then
                    for host in $hosts
                    do
                        hostip=$(echo $host | grep $smac | cut -d '"' -f 1)
                        if [ -n "$hostip" ] && [ "$hostip" != "0.0.0.0" ]; then
                            conntrack -D -s $hostip
                            break
                        fi
                    done
                fi
            fi
        else
            sip=$(echo $source | cut -d '"' -f 1) 
            if [ -n "$sip" ] && [ "$sip" != "0.0.0.0" ]; then
                iptables -A ACCESSPOLICY_$1 -i br0 -s $sip -j DROP
                conntrack -D -s $sip
            fi
        fi
    done        
}

disable()
{
    iptables -F ACCESSPOLICY_$1
}

if [ $2 == "enter" ]; then
    echo "enter"
    enable $1
elif [ $2 == "exit" ]; then
    echo "exit"
    disable $1
fi
