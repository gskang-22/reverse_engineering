#!/bin/sh
#The purpose is to make sure all ptm sub interfaces are reset when xdsl link becomes up.
#This is just a workaround. TBD later.
#Only ptm0 is supported. The sub interface name should begin with "ptm_".

subIntfs=$(ifconfig | grep ptm_ | awk '{print substr($1,1)}');

echo "XDSL_WAN:(1)reset ptm0"
ifconfig ptm0 down && ifconfig ptm0 up

echo "XDSL_WAN:(2)reset interfaces one by one"
for intf in $subIntfs 
do
    echo "reset interface: $intf"
    #ifconfig $intf
    ifconfig $intf down
    ifconfig $intf up
done

echo "XDSL_WAN:(3)Finish reseting ptm interfaces"