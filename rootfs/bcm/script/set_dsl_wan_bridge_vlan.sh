#!/bin/sh
#This script is used to create/delete bridge DSL WAN with VLAN translation
#This script should run after system boot up successfully

usage_print(){
    echo "usage: $0 <create|delete> <br_name> <lan_vid> <xdsl_wan_vid> <lan_intf>"
    echo "    create -- create bridge WAN with VLAN"
    echo "    delete -- delete bridge WAN"
    echo "    br_name -- bridge interface name eg,br10,br11"
    echo "    lan_vid -- VLAN ID supported for LAN ports"
    echo "    xdsl_wan_vid -- VLAN ID supported for XDSL WAN ports"
    echo "    lan_intf -- LAN ports intf added to the bridge VLAN"
    echo "          eth0  --> ether WAN "
    echo "          eth1  --> ether LAN port 1 (close to USB port) "
    echo "          eth2  --> ether LAN port 2 "
    echo "          eth3  --> ether LAN port 3 "
    echo "          eth4  --> ether LAN port 4 "
    echo " example: "
    echo "     sh set_dsl_wan_bridge_vlan.sh create br10 112 113 eth1 "
    echo "     sh set_dsl_wan_bridge_vlan.sh delete br10 112 113 eth1 "
}

g_br_name=br10
g_lan_vid=110
g_wan_vid=110
g_lan_intf=eth1

create_bridge_wan_vlan() {
    wan_vlan_intf=ptm0.$g_wan_vid
    lan_vlan_intf=$g_lan_intf.$g_lan_vid
    echo "Create: bridge [$g_br_name], lan_vlan_intf[$lan_vlan_intf], wan_vlan_intf [$wan_vlan_intf]"
    
    echo "create wan interfaces and rules ... "
    vlanctl --if-create-name ptm0  $wan_vlan_intf
    vlanctl --if  ptm0  --rx  --tags 1 --filter-vid $g_wan_vid 0 --pop-tag  --set-rxif $wan_vlan_intf --rule-append
    vlanctl --if  ptm0  --rx  --tags 2 --filter-vid $g_wan_vid 0 --pop-tag  --set-rxif $wan_vlan_intf --rule-append
    vlanctl --if  ptm0  --tx  --tags 0 --filter-txif  $wan_vlan_intf  --push-tag --set-vid $g_wan_vid 0 --set-pbits 0 0 --rule-append 
    vlanctl --if  ptm0  --tx  --tags 1 --filter-txif  $wan_vlan_intf  --push-tag --set-vid $g_wan_vid 0 --set-pbits 0 0 --rule-append 
    vlanctl --if  ptm0  --tx  --tags 2 --filter-txif  $wan_vlan_intf  --push-tag --set-vid $g_wan_vid 0 --set-pbits 0 0 --rule-append 
    
    echo "create LAN interfaces and rules ... "        
    vlanctl --if-create-name $g_lan_intf  $lan_vlan_intf
    vlanctl --if  $g_lan_intf  --rx  --tags 1 --filter-vid $g_lan_vid 0 --pop-tag --set-rxif  $lan_vlan_intf  --rule-append
    vlanctl --if  $g_lan_intf  --rx  --tags 2 --filter-vid $g_lan_vid 0 --pop-tag --set-rxif  $lan_vlan_intf  --rule-append
    vlanctl --if  $g_lan_intf  --tx  --tags 0 --filter-txif  $lan_vlan_intf  --push-tag --set-vid $g_lan_vid 0 --set-pbits 0 0 --rule-append
    vlanctl --if  $g_lan_intf  --tx  --tags 1 --filter-txif  $lan_vlan_intf  --push-tag --set-vid $g_lan_vid 0 --set-pbits 0 0 --rule-append
    vlanctl --if  $g_lan_intf  --tx  --tags 2 --filter-txif  $lan_vlan_intf  --push-tag --set-vid $g_lan_vid 0 --set-pbits 0 0 --rule-append
    
    echo "create bridge $g_br_name... "
    brctl addbr $g_br_name
    brctl addif $g_br_name $wan_vlan_intf 
    brctl addif $g_br_name $lan_vlan_intf 

    echo "UP bridge [$g_br_name], lan_vlan_intf[$lan_vlan_intf], wan_vlan_intf [$wan_vlan_intf]..."
    ifconfig  $wan_vlan_intf  down && ifconfig  $wan_vlan_intf  up    
    ifconfig  $lan_vlan_intf  down && ifconfig  $lan_vlan_intf  up 
    ifconfig  $g_br_name  down && ifconfig  $g_br_name  up 
}

delete_bridge_wan_vlan() {
    wan_vlan_intf=ptm0.$g_wan_vid
    lan_vlan_intf=$g_lan_intf.$g_lan_vid
    echo "Delete: bridge [$g_br_name], lan_vlan_intf[$lan_vlan_intf], wan_vlan_intf [$wan_vlan_intf]"

    ifconfig $wan_vlan_intf down
    ifconfig $lan_vlan_intf down
    ifconfig $g_br_name down

    brctl delif $g_br_name $wan_vlan_intf
    brctl delif $g_br_name $lan_vlan_intf
    brctl delbr $g_br_name
    
    vlanctl --if-delete $lan_vlan_intf
    vlanctl --if-delete $wan_vlan_intf
}

##############################################
# Main process
##############################################
if [ $# -lt 5 ]; then
    echo "Error: Request five arguments!"
    usage_print
    exit 1
fi

g_br_name=$2
g_lan_vid=$3
g_wan_vid=$4
g_lan_intf=$5

echo "args list: $1 $2 $3 $4 $5"

if [ $1 = "create" ]; then
    create_bridge_wan_vlan
    exit 0
fi

if [ $1 = "delete" ]; then
    delete_bridge_wan_vlan
    exit 0
fi

echo "Error: invalid argument $1 !"
usage_print
exit 0

##############################################
#end of this file
##############################################