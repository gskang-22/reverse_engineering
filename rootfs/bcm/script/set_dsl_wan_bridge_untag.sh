#!/bin/sh
#This script is used to active/deactive untag bridge DSL WAN
#This script should run after system boot up successfully

usage_print(){
    echo "usage: $0 <active|deactive>"
    echo "    active -- enable untag DSL WAN port and add it to the same bridge as LAN ports"
    echo "    deactive -- disable untag DSL WAN port "
}

active_bridge_untag() {
    vlanctl --if-create-name ptm0  ptm_u 
    vlanctl --if ptm0 --rx --tags 0 --set-rxif ptm_u  --rule-append

    vlanctl --if  ptm0  --tx  --tags 0 --filter-txif  ptm_u --rule-append
    vlanctl --if  ptm0  --tx  --tags 1 --filter-txif  ptm_u --rule-append
    vlanctl --if  ptm0  --tx  --tags 2 --filter-txif  ptm_u --rule-append

    brctl addif br0 ptm_u
    ifconfig ptm_u down
    ifconfig ptm_u up
}

deactive_bridge_untag() {
    brctl delif br0 ptm_u
    ifconfig ptm_u down
    vlanctl --if-delete ptm_u
}

##############################################
# Main process
##############################################
if [ $# -lt 1 ]; then
    echo "Error: Request one argument!"
    usage_print
    exit 1
fi

if [ $1 = "active" ]; then
    active_bridge_untag
    exit 0
fi

if [ $1 = "deactive" ]; then
    deactive_bridge_untag
    exit 0
fi

echo "Error: invalid argument $1 !"
usage_print
exit 0

##############################################
#end of this file
##############################################