#/bin/sh

start_time=180
wl_if="wl0.4"
link_up_flag="WDS_LINKUP"
invalid_flag="0 kbps - 4294967295 kbps"
need_check="true"
work_role="UNSELECTED"
auth_root_mac=""

is_wds_link_unexist=`wl wds | grep wds > /dev/null ; echo $?` 

is_invalid_wds_link()
{
	wl_if=$1
	mac=$2

	is_link_down=0
	is_valid_speed=1

	wl -i $wl_if sta_info $mac | grep "$link_up_flag" > /dev/null
	is_link_down=$?

	if [ $is_link_down = 0 ]
	then
		wl -i $wl_if sta_info $mac | grep "$invalid_flag" > /dev/null
		is_valid_speed=$?
	fi

	#if [ $is_link_down = 1 -o $is_valid_speed = 0 ]
	if [ $is_valid_speed = 0 ]
	then
		echo "yes"
	else
		echo "no"
	fi
	
}

get_work_role()
{
        while [ "x$work_role" != "xAgent" -a "x$work_role" != "xController" ]
        do
            sleep 2
            work_role=`cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole | cut -d = -f 2`
        done

        echo "current work role is $work_role"
}


get_check_wds_macs()
{
	if [ "x$work_role" = "xController" ]
	then
		wds_macs=`wl wds |grep wds | cut -d ' ' -f 2`
	else
		wds_macs=$auth_root_mac
	fi
	
	echo $wds_macs
}


check_wds_link()
{
	while [ "x$1" = "xtrue" ]
	do
		sleep 2
		
		macs=`get_check_wds_macs`
	
		for mac in $macs
		do
			sleep 2
			fail_count=0

			is_link_failed=`is_invalid_wds_link $wl_if $mac`
			#echo $mac is_link_failed is $is_link_failed

		
			while [ "x$is_link_failed" = "xyes" ]
			do
				let fail_count=fail_count+1
			
				if [ $fail_count = 15 ]
				then
					echo "wds link $mac is invalid, need to reset wds link"
					wl wds none
					is_link_failed="no"
					sleep 10
				else
					sleep 2
					is_link_failed=`is_invalid_wds_link $wl_if $mac`
					#echo $mac is_link_failed is $is_link_failed
				fi
			
			done

		done
	done
}

echo "Enter recover_wds script"

get_work_role

echo "start recover_wds script, work role is $work_role"

if [ "x$work_role" != "xController" ]
then
	sleep $start_time
	auth_root_mac=`cat /configs/root_beacon | cut -d ' ' -f 13`
	echo "Bridge mode beacon's auth_root_mac is $auth_root_mac"
	check_wds_link $need_check &
else
	echo "Currently ROOT doesn't need to run recover_wds.sh."
fi	

