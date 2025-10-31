#!/bin/sh
set -x

show_help() {
    echo "Usage: $0 [AllocId] [GEMPort] [VLAN0] [VLAN1] [VLAN2] [VLAN3]"
    echo "       Default value: AllocId - 256, GEMPort - 256, VLAN0 - 256, subsequent Lan(2,3,4) VLAN is (previous-VLAN + 1)"
    echo "       The arguments are values configured in MiniOLT, not index in RDPA."
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	show_help; exit 0
fi

AllocId=${1:-256}
GEMPort=${2:-256}
VLAN0=${3:-256}
VLAN1=${4:-$((VLAN0+1))}
VLAN2=${5:-$((VLAN1+1))}
VLAN3=${6:-$((VLAN2+1))}

echo "AllocId:" $AllocId
echo "GEMPort:" $GEMPort
echo "VLAN0:" $VLAN0
echo "VLAN1:" $VLAN1
echo "VLAN2:" $VLAN2
echo "VLAN3:" $VLAN3

# create gpon
# bs /bdmf/new gpon/onu_sn={vendor_id=0x414c434c,vendor_specific=0x38385050},link_activate=activate_O1,password=00000000000000000000

# create wan logic port, set gpon as its parent, and link it to bridge
# bs /bdmf/new port/index=wan0 gpon
# bs /bdmf/link port/index=wan0 bridge/index=0

# us tcont & gem configuration
bs /bdmf/new tcont/index=1

bs /bdmf/new egress_tm/dir=us,index=70,level=queue,mode=sp tcont/index=1
bs /bdmf/configure egress_tm/dir=us,index=70 queue_cfg[0]={drop_threshold=128,queue_id=0}

bs /b/c gpon tcont_alloc_id[{tcont/index=1}]=$AllocId

# create gem index#30
bs /bdmf/new gem/index=30,flow_type=ethernet,gem_port=$GEMPort,us_cfg={tcont={tcont/index=1}},ds_cfg={discard_prty=low,destination=eth}

bs /b/c gpon gem_enable[{gem/index=30}]=yes
bs /b/c gpon gem_ds_cfg[{gem/index=30}]={port=$GEMPort}

bs /b/n vlan_action/dir=us,index=10,action={cmd=0}
bs /b/n vlan_action/dir=ds,index=11,action={cmd=0}

#bs /b/d ingress_class/dir=ds,index=0
bs /b/new ingress_class/dir=us,index=10,cfg={type=flow,fields=vlan_num,prty=2}
bs /b/attr/add ingress_class/dir=us,index=10 flow string {key={vlan_num=1},result={forw_mode=flow,egress_port=wan0,qos_method=flow,wan_flow=30,queue_id=0,action=forward,vlan_action={vlan_action/dir=us,index=10}}}

bs /b/new ingress_class/dir=ds,index=11,cfg={type=flow,fields=outer_vid,prty=2}

gponif -a wan0 -g 30

for i in `seq 0 3`;
do
    a="VLAN"$i
    eval vlan=\$$a

    bs /b/n egress_tm/dir=ds,index=$i,level=queue,mode=sp port/index=lan$i
    bs /b/c egress_tm/dir=ds,index=$i queue_cfg[0]={drop_threshold=128,queue_id=0}

    bs /b/attr/add ingress_class/dir=ds,index=11 flow string {key={outer_vid=$vlan},result={forw_mode=flow,egress_port=lan$i,qos_method=flow,queue_id=0,action=forward,vlan_action={vlan_action/dir=ds,index=11}}}

#modify port dal=no
bs /b/c port/index=lan0 cfg={dal=no,dal_miss_action=forward}
bs /b/c port/index=lan1 cfg={dal=no,dal_miss_action=forward}
bs /b/c port/index=lan2 cfg={dal=no,dal_miss_action=forward}
bs /b/c port/index=lan3 cfg={dal=no,dal_miss_action=forward}
bs /b/c port/index=wan0 cfg={dal=no,dal_miss_action=forward}

    # remove all VLAN devices and add all base devices to br0
    vlanctl --if-delete eth$i.0
    brctl delif br1 eth$i
    brctl addif br0 eth$i
done
