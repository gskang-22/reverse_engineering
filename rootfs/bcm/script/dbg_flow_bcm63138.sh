##
## This script is used to get counters of BRCM63138 platform.
## Useage: 
##    cd /logs && sh /bcm/script/dbg_flow_bcm63138.sh  2>&1 | tee flow_issue_2015072001.txt
## History:    
##    20150716  -- MYH created
##    20150731  -- ADD more iptable and rdpa debug
##  

check_linux_intf(){
    echo "DEBUG: check linux interfaces "
    ifconfig
    ip addr
    ip rule show
    ip -6 rule show

    echo "DEBUG: check linux bridge"
    /bin/brctl show
    /bin/brctl showmacs br0
    /bin/brctl showstp  br0 

    echo "DEBUG: check linux ebtables"
    ebtables -L --Lc
    ebtables -t broute  -L --Lc
    ebtables -t nat -L --Lc
    
    echo "DEBUG: check linux iptables"
    iptables -L -v
    iptables -t filter -S -v
    iptables -t nat -S -v
    iptables -t mangle -S -v
    iptables-save
    ip6tables-save
    conntrack -L 
    conntrack -S

    echo "DEBUG: check linux mroute and igmp"
    cat /proc/net/igmp_snooping
    cat /proc/net/ip_mr_cache 
    cat /proc/net/ip_mr_vif 
}

check_rdpa(){
    echo "DEBUG: check rdpa objects "
    bs /b/e cpu  max_prints:-1
    bs /b/e port max_prints:-1
    bs /b/e ucast  max_prints:-1
    bs /b/e mcast  max_prints:-1
    bs /b/e egress_tm  max_prints:-1 
    bs /b/e xtmchannel max_prints:-1 
    bs /b/e xtmflow  max_prints:-1 
    cat /proc/fcache/*
    
    echo "DEBUG: dump all rdpa config"
    echo "bs /bdmf/ex system children:yes class:config max_prints:-1"
    bs /bdmf/ex system children:yes class:config max_prints:-1
    
    echo "DEBUG: Display all non-zero statistics system-wide"
    echo "bs /bdmf/examine system class:nzstat children:yes"
    bs /bdmf/examine system class:nzstat children:yes 

    echo "DEBUG: Print packet drop reason"
    bs /d/r pvdc 0 
    bs /d/r pvdc 1
}

check_vlanctl(){
    echo "DEBUG: VLANCTL "
    dmesg -n 8

    for INTF in ptm0 eth1 eth2 eth3 eth4
    do 
        echo "DEBUG: dump vlanctl rule of intf: " $INTF 
        vlanctl --if $INTF  --all 
        dmesg
    done
}

check_dsl_xtm(){
    echo "DEBUG: XDSL && XTM "
    xdslctl info --version
    xtmctl bonding --status
    xtmctl operate conn --show 
    xdslctl profile --show 

    xdslctl info --stats
    xtmctl operate intf --stats
}

check_dsl_switch(){
    echo "DEBUG: SF switch"
    echo "DEBUG: dump MAC table of SF switch"
    ethswctl -c arldump
    dmesg | tail -n 64

    echo "DEBUG: SF switch port maping: ext switch port -- linux intf"
    echo " 0 -- eth1, 1 -- eth2, 2 -- eth3, 3 -- eth4, 5 -- eth5, 8 -- IMP runner"
    for SWPORT in 0 1 2 3 5 8
    do 
        echo "DEBUG: dump switch counter of port " $SWPORT 
        ethswctl -c mibdump -p $SWPORT -a
        dmesg | tail -n 64
    done
}

#The counter is read-clear.
check_sar_register(){
    echo "DEBUG: dump SAR registers"
    xtmctl sar all
}

check_system(){
    echo "DEBUG: dump system status"
    top -b -d 1 -n 3
    ps -w 
    cat /proc/meminfo 
}

##############################################
# Main process
##############################################
echo "Test Script: dbg_flow_bcm63138.sh version 0.4"
echo "===============TEST Begin==============="
date 
cat /usr/etc/buildinfo 
ritool dump
check_system

echo "===============Run One==================="
check_linux_intf
check_dsl_switch
check_rdpa
check_vlanctl
check_dsl_xtm

echo "===============SLEEP 10 seconds=================="
sleep 10

echo "===============Run TWO==================="
check_linux_intf
check_dsl_switch
check_rdpa
check_vlanctl
check_dsl_xtm

echo "===============SLEEP 10 seconds=================="
sleep 10

echo "===============Run THREE==================="
check_linux_intf
check_dsl_switch
check_rdpa
check_vlanctl
check_dsl_xtm

echo "===============Check XDSL WAN==================="
check_dsl_xtm
check_sar_register
sleep 10
check_dsl_xtm
check_sar_register
sleep 10
check_dsl_xtm
check_sar_register
echo "===============TEST End==============="

##############################################
#end of this file
##############################################

