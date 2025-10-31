#!/bin/sh
#$1:changed ip address
#$2:host ifname
#$3:QTN eth mac address
if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
		br0_ip=$1
		new_ip=$(echo $1 | awk -F. '{print $1"."$2"."$3"."200}')
		#echo "$new_ip"
		#old_ip=$(cat /etc/qcsapi_target_ip.conf)
		#echo "$old_ip"
		#if [ "$new_ip" != "$old_ip" ]; then
			revert_ip=$(echo $new_ip | awk -F. '{print $4"."$3"."$2"."$1}')
			qcsapi_sockraw $2 $3 set_ip br0 ipaddr $new_ip
			qcsapi_sockraw $2 $3 store_ipaddr $revert_ip
			qcsapi_sockraw $2 $3 run_script remote_command route_add $br0_ip
			echo $new_ip > /etc/qcsapi_target_ip.conf
		#	echo "changed"
		#else
		#	echo "not change"
		#fi
fi