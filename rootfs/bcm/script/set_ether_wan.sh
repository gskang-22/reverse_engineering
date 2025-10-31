#!/bin/sh
#This script is used to active/deactive WAN ports of F240WA
#This script should run after system boot up successfully

usage_print(){
    echo "usage: $0 <active|deactive>"
    echo "    active -- enable WAN port and add it to the same bridge as LAN ports"
    echo "    deactive -- disable WAN port"
}

active_ether_wan() {
    echo "Ether WAN:(1)Create TM for WAN port"
    bs /bdmf/new egress_tm/dir=us,index=16,level=queue,mode=sp port/index=wan0
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[0]={queue_id=0,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[1]={queue_id=1,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[2]={queue_id=2,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[3]={queue_id=3,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[4]={queue_id=4,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[5]={queue_id=5,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[6]={queue_id=6,weight=0,drop_alg=dt,drop_threshold=512}
    bs /bdmf/configure egress_tm/dir=us,index=16 queue_cfg[7]={queue_id=7,weight=0,drop_alg=dt,drop_threshold=512}
    
    echo "Ether WAN:(2)Enable WAN port eth0"
    ethswctl -c wan -i eth0 -o enable
    
    echo "Ether WAN:(3)Add eth0 to br0"
    /bin/brctl addif br0 eth0
}

deactive_ether_wan() {
    echo "Ether WAN:(1)Remove eth0 from br0"
    /bin/brctl delif br0 eth0
    
    echo "Ether WAN:(2)Disable WAN port eth0"
    ethswctl -c wan -i eth0 -o disable
    
    echo "Ether WAN:(3)Delete TM of WAN port"
    bs /bdmf/delete egress_tm/dir=us,index=16
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
    active_ether_wan
    exit 0
fi

if [ $1 = "deactive" ]; then
    deactive_ether_wan
    exit 0
fi

echo "Error: invalid argument $1 !"
usage_print
exit 0

##############################################
#end of this file
##############################################
